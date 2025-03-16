from PySide2.QtCore import QObject, Slot, Signal
import threading
from time import sleep
from datetime import datetime, date

from controllers.DS18B20 import DS18B20
from controllers.Shelly import Shelly
from controllers.SolarDataCollector import SolarDataCollector, MODBUS_ERROR_TIMEOUT
from controllers.SolarWaterStorageController import SolarWaterStorageController

from libs.tinyflux import TimeQuery

from constants import DS18B20_SENSORPIN


class homePage(QObject):
    def __init__(self, settings, db):
        QObject.__init__(self)
        self.settings = settings
        self.shelly = Shelly(self.settings.get("SHELLY_HOST"))
        self.sdc = SolarDataCollector(self.settings.get("SDC_HOST"))
        self.swsc = SolarWaterStorageController(self.settings.get("SWSC_HOST"))
        self.temp = DS18B20(DS18B20_SENSORPIN)
        self.db = db
        self.get_data_running = False

    data = Signal(float, float, float, str, float, float, arguments = ["inverterAVP", "inverterDEC", "total_power", "boiler_status", "boiler_temp", "room_temp"])
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
        while self.get_data_running:
            try:
                dataEnergy = self.shelly.get_status()
                dataSolar = self.sdc.get_ivdata()
                dataWater = self.swsc.get_status()
                dataTemp = self.temp.get_temperature()
                if dataSolar == MODBUS_ERROR_TIMEOUT and not self.settings.get("NIGHT_TIME_RANGE")[0] < datetime.now().hour < self.settings.get("NIGHT_TIME_RANGE")[1]:
                    idpquery = TimeQuery() >= datetime(date.today().year, date.today().month, date.today().day)
                    try:
                        idp = self.db.search(idpquery, measurement="inverterDayPower")[-1].fields["kW/h"]
                    except IndexError:
                        idp = 0
                    self.data.emit(0, idp, dataEnergy["total_power"], dataWater["state"], dataWater["boilertemp"], dataTemp)
                else:
                    self.data.emit(dataSolar["inverterAVP"], dataSolar["inverterDEC"], dataEnergy["total_power"], dataWater["state"], dataWater["boilertemp"], dataTemp)
            except Exception as errorStr:
                self.error.emit(repr(errorStr))
            sleep(self.settings.get("DATA_REFRESH_RATE"))
