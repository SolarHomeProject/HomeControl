from PySide2.QtCore import QObject, Slot, Signal
from datetime import datetime, date, time, timedelta
import threading
from time import sleep

from controllers.SolarWaterStorageController import SolarWaterStorageController, DEVICE_MODES

from libs.tinyflux import TimeQuery


class boilerPage(QObject):
    def __init__(self, settings, db):
        QObject.__init__(self)
        self.settings = settings
        self.db = db
        self.swsc = SolarWaterStorageController(self.settings.get("SWSC_HOST"))
        self.get_data_running = False

    data = Signal("QVariant")
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
                self.data.emit(self.swsc.get_status())
            except Exception as errorStr:
                self.error.emit(repr(errorStr))
            sleep(self.settings.get("DATA_REFRESH_RATE"))

    @Slot(str)
    def get_db_data(self, query = "today"):
        Time = TimeQuery()
        if query == "today":
            tquery = datetime(date.today().year, date.today().month, date.today().day)
            result = self.db.search(Time >= tquery, measurement="boiler_temp")
        elif query == "yesterday":
            tquery1 = Time >= datetime.combine(date.today() - timedelta(days=1), time())
            tquery2 = Time <= datetime.combine(date.today() - timedelta(days=1), time(23, 59, 59))
            result = self.db.search(tquery1 & tquery2, measurement="boiler_temp")
        data = {}
        for point in result:
            data[point.time.strftime("%H:%M")] = point.fields["C"]
        self.datadb.emit(data)

    @Slot(result = "QVariantList")
    def get_devicemodes(self):
        return list(DEVICE_MODES.values())

    @Slot(result = int)
    def get_mode(self):
        return self.swsc.get_settings()["device_mode"]

    @Slot(result = int)
    def get_waterttemp(self):
        return self.swsc.get_settings()["water_t_temp"]

    @Slot(int, int, result = bool)
    def set_settings(self, device_mode, waterttemp):
        return self.swsc.set_device_mode(device_mode) and self.swsc.set_water_target_temp(waterttemp)

    @Slot()
    def clear_failstore(self):
        return self.swsc.clear_failstore()
