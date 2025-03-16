from ctypes import CDLL, CFUNCTYPE, POINTER, c_int, c_ubyte
import smbus2
from os import path

VL53L0X_ACCURACY_MODE_GOOD = 0        # 33 ms timing budget 1.2m range
VL53L0X_ACCURACY_MODE_BETTER = 1      # 66 ms timing budget 1.2m range
VL53L0X_ACCURACY_MODE_BEST = 2        # 200 ms 1.2m range
VL53L0X_ACCURACY_MODE_LONG_RANGE = 3  # 33 ms timing budget 2m range
VL53L0X_ACCURACY_MODE_HIGH_SPEED = 4  # 20 ms timing budget 1.2m range

VL53L0X_API_LIB_SO = "vl53l0x_python.cpython-39-aarch64-linux-gnu.so"


class VL53L0X:
    class VL53L0XError(Exception):
        pass

    class LoadSharedLibError(VL53L0XError):
        def __repr__(self):
            return "Load of VL53L0X shared lib failed"

    class DeviceReadError(VL53L0XError):
        def __repr__(self):
            return "Failed to read VL53L0X sensor"

    def __init__(self, i2c_address, i2c_bus=1):
        self._i2c_address = i2c_address
        self._bus = smbus2.SMBus(i2c_bus)
        self._load_lib()
        self._configure_i2c_library_functions()
        self._dev = self._VL53L0X_API.initialise(self._i2c_address, 255, 0)
        self._VL53L0X_API.startRanging(self._dev, VL53L0X_ACCURACY_MODE_GOOD)

    #Stop communication
    def stop(self):
        self._VL53L0X_API.stopRanging(self._dev)
        self._bus.close()

    #Get distance from VL53L0X ToF Sensor
    def get_distance(self):
        dist = self._VL53L0X_API.getDistance(self._dev)

        if dist == -1:
            raise VL53L0X.DeviceReadError

        return dist

    #I2C bus read callback for low level library.
    def _configure_i2c_library_functions(self):
        def _i2c_read(address, reg, data_p, length):
            ret_val = 0
            result = []

            try:
                result = self._bus.read_i2c_block_data(address, reg, length)
            except IOError:
                ret_val = -1

            if ret_val == 0:
                for index in range(length):
                    data_p[index] = result[index]

            return ret_val

        #I2C bus write callback for low level library.
        def _i2c_write(address, reg, data_p, length):
            ret_val = 0
            data = []

            for index in range(length):
                data.append(data_p[index])
            try:
                self._bus.write_i2c_block_data(address, reg, data)
            except IOError:
                ret_val = -1

            return ret_val

        #Read/write function pointer types.
        _I2C_READ_FUNC = CFUNCTYPE(c_int, c_ubyte, c_ubyte, POINTER(c_ubyte), c_ubyte)
        _I2C_WRITE_FUNC = CFUNCTYPE(c_int, c_ubyte, c_ubyte, POINTER(c_ubyte), c_ubyte)
        #Pass i2c read/write function pointers to VL53L0X library.
        self._i2c_read_func = _I2C_READ_FUNC(_i2c_read)
        self._i2c_write_func = _I2C_WRITE_FUNC(_i2c_write)
        self._VL53L0X_API.VL53L0X_set_i2c(self._i2c_read_func, self._i2c_write_func)

    #Load VL53L0X shared lib
    def _load_lib(self):
        try:
            self._VL53L0X_API = CDLL(path.join(path.dirname(path.abspath(__file__)), VL53L0X_API_LIB_SO))
        except OSError:
            raise VL53L0X.LoadSharedLibError
