from PySide2.QtCore import QObject, Slot, Signal
from datetime import datetime, date, time, timedelta
import threading
from time import sleep

from controllers.SolarDataCollector import SolarDataCollector, MODBUS_ERROR_TIMEOUT, TEMP_DEVICE_DISCONNECTED_C

from libs.tinyflux import TimeQuery


class solarPage(QObject):
    def __init__(self, settings, db):
        QObject.__init__(self)
        self.settings = settings
        self.sdc = SolarDataCollector(self.settings.get("SDC_HOST"))
        self.db = db
        self.get_data_running = False

    data = Signal("QVariant")
    datadb = Signal("QVariantList", "QVariantList", arguments = ["times", "values"])
    error = Signal(str)

    @Slot()
    def active(self):
        self.data_thread = threading.Thread(target=self.get_data)
        self.get_data_running = True
        self.data_thread.start()

    @Slot()
    def inactive(self):
        self.get_data_running = False

    @Slot(result = int)
    def get_temp_disconnected(self):
        return TEMP_DEVICE_DISCONNECTED_C

    def get_data(self):
        self.get_db_data()
        while self.get_data_running:
            try:
                dataSolar = self.sdc.get_data()
                if dataSolar == MODBUS_ERROR_TIMEOUT and not self.settings.get("NIGHT_TIME_RANGE")[0] < datetime.now().hour < self.settings.get("NIGHT_TIME_RANGE")[1]:
                    self.error.emit("Data not available")
                    continue
                self.data.emit(dataSolar)
            except Exception as errorStr:
                self.error.emit(repr(errorStr))
            sleep(self.settings.get("DATA_REFRESH_RATE"))

    @Slot(str)
    def get_db_data(self, query = "today"):
        Time = TimeQuery()
        if query == "today":
            tquery = datetime(date.today().year, date.today().month, date.today().day)
            result = self.db.search(Time >= tquery, measurement="inverterCurrentPower")
            strftimestr = "%H:%M"
            field = "W"
        elif query == "yesterday":
            tquery1 = Time >= datetime.combine(date.today() - timedelta(days=1), time())
            tquery2 = Time <= datetime.combine(date.today() - timedelta(days=1), time(23, 59, 59))
            result = self.db.search(tquery1 & tquery2, measurement="inverterCurrentPower")
            strftimestr = "%H:%M"
            field = "W"
        elif query == "year":
            tquery = datetime(date.today().year, 1, 1)
            result = self.db.search(Time >= tquery, measurement="inverterDayPower")
            strftimestr = "%d.%m."
            field = "kW/h"
        times = []
        values = []
        for point in result:
            times.append(point.time.strftime(strftimestr))
            values.append(point.fields[field])
        self.datadb.emit(times, values)
