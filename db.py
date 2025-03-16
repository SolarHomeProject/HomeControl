from datetime import datetime, date, time, timedelta
import threading
from time import sleep

from controllers.Shelly import Shelly
from controllers.SolarDataCollector import SolarDataCollector
from controllers.SolarWaterStorageController import SolarWaterStorageController

from libs.tinyflux import Point, TimeQuery, MeasurementQuery
from libs.schedule import Scheduler


class DBWorker:
    def __init__(self, settings, db, fs):
        self.settings = settings
        self.db = db
        self.failstore = fs
        self.shelly = Shelly(self.settings.get("SHELLY_HOST"))
        self.sdc = SolarDataCollector(self.settings.get("SDC_HOST"))
        self.swsc = SolarWaterStorageController(self.settings.get("SWSC_HOST"))
        self.scheduler = Scheduler()
        self.update_interval()
        self.scheduler_thread = threading.Thread(target=self.run_scheduler)
        self.running = False
        self.insert_running = False

    def update_interval(self, clear = False):
        if clear:
            self.scheduler.clear()
        self.scheduler.every().day.at("00:00").do(self.db_clean_worker)
        self.scheduler.every(self.settings.get("DB_DATA_INSERT_RATE")).seconds.do(self.db_insert_worker)

    def start(self):
        self.running = True
        self.scheduler_thread.start()

    def stop(self):
        while self.insert_running:
            pass
        self.running = False

    def db_clean_worker(self):
        try:
            self.insert_running = True
            Time = TimeQuery()
            l2d = datetime.now() - timedelta(days=2)
            self.db.remove(Time < l2d, measurement = "inverterCurrentPower")
            self.db.remove(Time < l2d, measurement = "total_power")
            self.db.remove(Time < l2d, measurement = "boiler_temp")
            ly = datetime.combine(date(date.today().year - 1, 12, 31), time(23, 59, 59))
            self.db.remove(Time <= ly, measurement = "inverterDayPower")
        except Exception as e:
            self.failstore.add_entry("DB clean worker", e)
        finally:
            self.insert_running = False

    def db_insert_worker(self):
        try:
            self.insert_running = True

            dataEnergy = self.shelly.get_status()
            p = Point(time = datetime.now(), measurement = "total_power", fields = {"W": dataEnergy["total_power"]})
            self.db.insert(p)

            dataWater = self.swsc.get_status()
            p = Point(time = datetime.now(), measurement = "boiler_temp", fields = {"C": dataWater["boilertemp"]})
            self.db.insert(p)

            dataSolar = self.sdc.get_ivdata()
            p = Point(time = datetime.now(), measurement = "inverterCurrentPower", fields = {"W": dataSolar["inverterAVP"]})
            self.db.insert(p)

            Time = TimeQuery()
            Measurement = MeasurementQuery()
            q1 = Time >= datetime.combine(date.today(), time())
            q2 = Time <= datetime.combine(date.today(), time(23, 59, 59))
            for point in self.db.search(q1 & q2, measurement="inverterDayPower"):
                self.db.remove((Time == point.time) & (Measurement == point.measurement))

            p = Point(time = datetime.now(), measurement = "inverterDayPower", fields = {"kW/h": dataSolar["inverterDEC"]})
            self.db.insert(p)
        except:
            pass
        finally:
            self.insert_running = False

    def run_scheduler(self):
        self.scheduler.run_all()
        while self.running:
            self.scheduler.run_pending()
            sleep(1)
