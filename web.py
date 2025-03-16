from flask import Flask, jsonify, abort, send_file, request, session, redirect
from cheroot import wsgi
from datetime import datetime, date, time, timedelta
import mimetypes
import os
import secrets

from controllers.Shelly import Shelly
from controllers.SolarDataCollector import SolarDataCollector, MODBUS_ERROR_TIMEOUT, TEMP_DEVICE_DISCONNECTED_C
from controllers.SolarWaterStorageController import SolarWaterStorageController

from libs.tinyflux import TimeQuery

import globals

SAVE_STATIC_EXT = (".css", ".js")
SFILE_PATH = "web/sfile"
SAVE_IMG_EXT = (".jpg", ".png")
IMG_URL = "/images/img"


class Web:
    def __init__(self, settings, db, port, bind_addr):
        self._settings = settings
        self._db = db
        self._port = port
        self._bind_addr = bind_addr
        self._shelly = Shelly(self._settings.get("SHELLY_HOST"))
        self._sdc = SolarDataCollector(self._settings.get("SDC_HOST"))
        self._swsc = SolarWaterStorageController(self._settings.get("SWSC_HOST"))
        self.app = Flask(__name__, static_folder = "web/static", template_folder = None)
        if not self._settings.has_option("FLASK_SEC_KEY"):
            self._settings.setsave("FLASK_SEC_KEY", secrets.token_hex())
        self.app.secret_key = self._settings.get("FLASK_SEC_KEY")
        self._wsgi = wsgi.Server((self._bind_addr, self._port), self.app)
        self.app.add_url_rule("/", view_func = self.get_index, methods = ["GET"])
        self.app.add_url_rule("/login", view_func = self.get_login, methods = ["GET"])
        self.app.add_url_rule("/settings", view_func = self.get_settings, methods = ["GET"])
        self.app.add_url_rule("/sfile/<file>", view_func = self.get_sfile, methods = ["GET"])
        self.app.add_url_rule("/dashboard", view_func = self.get_dashboard, methods = ["GET"])
        self.app.add_url_rule("/energy", view_func = self.get_energy, methods = ["GET"])
        self.app.add_url_rule("/solar", view_func = self.get_sdc, methods = ["GET"])
        self.app.add_url_rule("/boiler", view_func = self.get_swsc, methods = ["GET"])
        self.app.add_url_rule("/dbdata/<type>/<query>", view_func = self.get_dbdata, methods = ["GET"])
        self.app.add_url_rule("/images", view_func = self.get_images, methods = ["GET"])
        self.app.add_url_rule(f"{IMG_URL}/<img>", view_func = self.get_images_img, methods = ["GET"])
        self.app.add_url_rule("/auth/session", view_func = self.post_auth_session, methods = ["POST"])
        self.app.add_url_rule("/auth/session", view_func = self.del_auth_session, methods = ["DELETE"])

    def start(self):
        self._wsgi.start()

    def stop(self):
        self._wsgi.stop()

    def _session_auth(call):
        def _wrapped(self, *args, **kwargs):
            if not "authenticated" in session:
                return abort(401)
            return call(self, *args, **kwargs)
        _wrapped.__name__ = call.__name__
        return _wrapped

    def get_index(self):
        if not "authenticated" in session:
          return redirect("/login")
        return self.app.send_static_file("index.html")

    def get_login(self):
        if "authenticated" in session:
          return redirect("/")
        return self.app.send_static_file("login.html")

    @_session_auth
    def get_settings(self):
        return jsonify({"refresh_rate": self._settings.get("DATA_REFRESH_RATE"), "temp_dev_disconnected_c": TEMP_DEVICE_DISCONNECTED_C})

    @_session_auth
    def get_sfile(self, file):
        if not file or not file.endswith(SAVE_STATIC_EXT):
            return abort(404)

        sfiles = [file for file in os.listdir(SFILE_PATH) if os.path.isfile(os.path.join(SFILE_PATH, file))]
        if file in sfiles:
            return send_file(os.path.join(SFILE_PATH, file), mimetype = mimetypes.guess_type(file)[0])
        else:
            return abort(404)

    @_session_auth
    def get_dashboard(self):
        shelly_data = self._shelly.get_status()
        sdc_data = self._sdc.get_ivdata()
        swsc_data = self._swsc.get_status()
        if sdc_data == MODBUS_ERROR_TIMEOUT and not self._settings.get("NIGHT_TIME_RANGE")[0] < datetime.now().hour < self._settings.get("NIGHT_TIME_RANGE")[1]:
            sdc_data["inverterAVP"] = 0
            idpquery = TimeQuery() >= datetime(date.today().year, date.today().month, date.today().day)
            try:
                sdc_data["inverterDEC"] = self._db.search(idpquery, measurement="inverterDayPower")[-1].fields["kW/h"]
            except IndexError:
                sdc_data["inverterDEC"] = 0
        data = shelly_data | sdc_data | swsc_data
        return jsonify(data)

    @_session_auth
    def get_energy(self):
        return jsonify(self._shelly.get_status())

    @_session_auth
    def get_sdc(self):
        return jsonify(self._sdc.get_data())

    @_session_auth
    def get_swsc(self):
        return jsonify(self._swsc.get_status())

    @_session_auth
    def get_dbdata(self, type, query):
        if ((type == "energy") and (query == "today" or query == "yesterday")):
            mm = "total_power"
            field = "W"
        elif ((type == "solar") and (query == "today" or query == "yesterday")):
            mm = "inverterCurrentPower"
            field = "W"
        elif type == "solar" and query == "year":
            mm = "inverterDayPower"
            field = "kW/h"
        elif ((type == "boiler") and (query == "today" or query == "yesterday")):
            mm = "boiler_temp"
            field = "C"
        else:
            return abort(404)

        Time = TimeQuery()
        if query == "today":
            tquery = datetime(date.today().year, date.today().month, date.today().day)
            result = self._db.search(Time >= tquery, measurement=mm)
            strftimestr = "%H:%M"
        elif query == "yesterday":
            tquery1 = Time >= datetime.combine(date.today() - timedelta(days=1), time())
            tquery2 = Time <= datetime.combine(date.today() - timedelta(days=1), time(23, 59, 59))
            result = self._db.search(tquery1 & tquery2, measurement=mm)
            strftimestr = "%H:%M"
        elif query == "year":
            tquery = datetime(date.today().year, 1, 1)
            result = self._db.search(Time >= tquery, measurement=mm)
            strftimestr = "%d.%m."

        times = []
        values = []
        for point in result:
            times.append(point.time.strftime(strftimestr))
            values.append(point.fields[field])

        return jsonify({"time": times, "value": values})

    @_session_auth
    def get_images(self):
        images = []
        for path, _, files in os.walk(globals.FTP_PATH):
            for file in files:
                if file.endswith(SAVE_IMG_EXT):
                    images.append({"url": os.path.join(IMG_URL, file), "date": datetime.fromtimestamp(os.path.getmtime(os.path.join(path, file))).strftime("%H:%M %d.%m.%Y")})
        return jsonify(images)

    @_session_auth
    def get_images_img(self, img):
        if not img or not img.endswith(SAVE_IMG_EXT):
            return abort(404)
        for path, _, files in os.walk(globals.FTP_PATH):
            for file in files:
                if file == img:
                    return send_file(os.path.join(path, img), mimetype = mimetypes.guess_type(img)[0])
                else:
                    continue
        return abort(404)

    def post_auth_session(self):
        password = request.json["password"]
        if password == self._settings.get("WEB_PW"):
            session["authenticated"] = True
            return jsonify({"authenticated": True})
        else:
            return abort(401)

    def del_auth_session(self):
        session.clear()
        return jsonify({"authenticated": False})
