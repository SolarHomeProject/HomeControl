from os import path, listdir
import subprocess
from time import sleep

DEGREES_C = 0x01
DEGREES_F = 0x02
KELVIN = 0x03
TEMP_COMP_VAL_CK = 25.8
TEMP_COMP_VAL_F = 49.44
BASE_DIRECTORY = "/sys/bus/w1/devices"
SLAVE_PREFIX = "28-"
SLAVE_FILE = "w1_slave"
UNIT_FACTORS = {DEGREES_C: lambda x: x * 0.001 - TEMP_COMP_VAL_CK, DEGREES_F: lambda x: x * 0.001 * 1.8 + 32.0 - TEMP_COMP_VAL_F, KELVIN: lambda x: x * 0.001 + 273.15 - TEMP_COMP_VAL_CK}


class DS18B20:
    class DS18B20Error(Exception):
        pass

    class NoSensorFoundError(DS18B20Error):
        def __init__(self, sensor_id):
            self._sensor_id = sensor_id

        def __repr__(self):
            if self._sensor_id:
                return f"No DS18B20 temperature sensor with id '{self._sensor_id}' found"
            return "No DS18B20 temperature sensor found"

    class SensorNotReadyError(DS18B20Error):
        def __repr__(self):
            return "Sensor is not yet ready to read temperature"

    class UnsupportedUnitError(DS18B20Error):
        def __str__(self):
            return "Only Degress C, F and Kelvin are supported"

    class KernelModuleLoadError(DS18B20Error):
        def __repr__(self):
            return "Load of kernel-module w1-gpio failed"

    def __init__(self, sensor_pin, sensor_id=None):
        self._sensorpin = sensor_pin
        self._id = sensor_id
        self._load_kernel_modules()
        self._sensor = self._get_sensor()

    @classmethod
    #Returns all available sensors
    def get_available_sensors(cls):
        sensors = []
        for sensor in listdir(BASE_DIRECTORY):
            if sensor.startswith(SLAVE_PREFIX):
                sensors.append(sensor[3:])
        return sensors

    @classmethod
    #Returns an instance for every available DS18B20 sensor
    def get_all_sensors(cls):
        return [DS18B20(sensor_id) for sensor_id in cls.get_available_sensors()]

    #Returns the id of the sensor
    def get_id(self):
        return self._id

    #Returns True if the sensor exists and is available to read temperature
    def exists(self):
        path = self._get_sensor()
        return path is not None

    #Returns the sensors slave path
    def _get_sensor(self):
        sensors = self.get_available_sensors()

        if not sensors:
            raise DS18B20.NoSensorFoundError(sensor_id=None)

        if self._id and self._id not in sensors:
            raise DS18B20.NoSensorFoundError(self._id)

        if not self._id:
            self._id = sensors[0]

        return path.join(BASE_DIRECTORY, SLAVE_PREFIX + self._id, SLAVE_FILE)

    #Returns the raw sensor value
    def _get_sensor_value(self):
        with open(self._sensor, "r") as f:
            data = f.readlines()

        if data[0].strip()[-3:] != "YES":
            raise DS18B20.SensorNotReadyError()
        return float(data[1].split("=")[1])

    #Returns the unit factor depending on the unit constant
    def _get_unit_factor(self, unit):
        try:
            return UNIT_FACTORS[unit]
        except KeyError:
            raise DS18B20.UnsupportedUnitError()

    #Returns the temperature in the specified unit
    def get_temperature(self, unit=DEGREES_C):
        factor = self._get_unit_factor(unit)
        sensor_value = self._get_sensor_value()
        return round(factor(sensor_value), 1)

    #Returns the temperatures in the specified units
    def get_temperatures(self, units):
        sensor_value = self._get_sensor_value()
        temperatures = []
        for unit in units:
            factor = self._get_unit_factor(unit)
            temperatures.append(round(factor(sensor_value), 1))
        return temperatures

    #Load kernel module needed by the temperature sensor
    def _load_kernel_modules(self):
        if not path.exists(BASE_DIRECTORY):
          try:
            subprocess.check_call(["dtoverlay", "w1-gpio", f"gpiopin={self._sensorpin}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            while not path.exists(BASE_DIRECTORY):
                pass
            #Wait for sensor detection
            sleep(0.2)
          except subprocess.CalledProcessError:
              raise DS18B20.KernelModuleLoadError
