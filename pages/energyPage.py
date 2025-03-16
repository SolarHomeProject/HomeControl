from PySide2.QtCore import QObject, Slot, Signal
from datetime import datetime, date, time, timedelta
import threading
from time import sleep

from controllers.Shelly import Shelly

from libs.tinyflux import TimeQuery


class energyPage(QObject):
    def __init__(self, settings, db):
        QObject.__init__(self)
        self.settings = settings
        self.shelly = Shelly(self.settings.get("SHELLY_HOST"))
        self.db = db
        self.get_data_running = False

    data = Signal(float, float, float, float, float, float, float, float, float, float, arguments = ["l1p", "l1a", "l1v", "l2p", "l2a", "l2v", "l3p", "l3a", "l3v", "total_power"])
    datadb = Signal("QVariant")
    error = Signal(str)

    @Slot()
    def active(self):
        self.data_thread = threading.Thread(target=self.get_data)
        self.get_data_running = True
        self.data_thread.start()

    @Slot()
    def inactive(self):
        self.get_data_running = False

    def get_data(self):
        self.get_db_data()
        while self.get_data_running:
            try:
                dataEnergy = self.shelly.get_status()
                self.data.emit(dataEnergy["emeters"][0]["power"], dataEnergy["emeters"][0]["current"], dataEnergy["emeters"][0]["voltage"], dataEnergy["emeters"][1]["power"], dataEnergy["emeters"][1]["current"], dataEnergy["emeters"][1]["voltage"], dataEnergy["emeters"][2]["power"], dataEnergy["emeters"][2]["current"], dataEnergy["emeters"][2]["voltage"], dataEnergy["total_power"])
            except Exception as errorStr:
                self.error.emit(repr(errorStr))
            sleep(self.settings.get("DATA_REFRESH_RATE"))

    @Slot(str)
    def get_db_data(self, query = "today"):
        Time = TimeQuery()
        if query == "today":
            tquery = datetime(date.today().year, date.today().month, date.today().day)
            result = self.db.search(Time >= tquery, measurement="total_power")
        elif query == "yesterday":
            tquery1 = Time >= datetime.combine(date.today() - timedelta(days=1), time())
            tquery2 = Time <= datetime.combine(date.today() - timedelta(days=1), time(23, 59, 59))
            result = self.db.search(tquery1 & tquery2, measurement="total_power")
        data = {}
        for point in result:
            data[point.time.strftime("%H:%M")] = point.fields["W"]
        self.datadb.emit(data)
