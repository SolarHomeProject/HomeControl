import requests

TEMP_DEVICE_DISCONNECTED_C = -127

MODBUS_ERROR_ILLEGAL_FUNCTION =       {"error": "Error response: ID: 1 Message: Illegal function code"}
MODBUS_ERROR_ILLEGAL_DATA_ADDRESS =   {"error": "Error response: ID: 2 Message: Illegal data address"}
MODBUS_ERROR_ILLEGAL_DATA_VALUE =     {"error": "Error response: ID: 3 Message: Illegal data value"}
MODBUS_ERROR_SERVER_DEVICE_FAILURE =  {"error": "Error response: ID: 4 Message: Server device failure"}
MODBUS_ERROR_ACKNOWLEDGE =            {"error": "Error response: ID: 5 Message: Acknowledge"}
MODBUS_ERROR_SERVER_DEVICE_BUSY =     {"error": "Error response: ID: 6 Message: Server device busy"}
MODBUS_ERROR_NEGATIVE_ACKNOWLEDGE =   {"error": "Error response: ID: 7 Message: Negative acknowledge"}
MODBUS_ERROR_MEMORY_PARITY_ERROR =    {"error": "Error response: ID: 8 Message: Memory parity error"}
MODBUS_ERROR_GATEWAY_PATH_UNAVAIL =   {"error": "Error response: ID: 10 Message: Gateway path unavailable"}
MODBUS_ERROR_GATEWAY_TARGET_NO_RESP = {"error": "Error response: ID: 11 Message: Gateway target not responding"}
MODBUS_ERROR_TIMEOUT =                {"error": "Error response: ID: 224 Message: Timeout"}
MODBUS_ERROR_INVALID_SERVER =         {"error": "Error response: ID: 225 Message: Invalid server"}
MODBUS_ERROR_CRC_ERROR =              {"error": "Error response: ID: 226 Message: CRC check error"}
MODBUS_ERROR_FC_MISMATCH =            {"error": "Error response: ID: 227 Message: Function code mismatch"}
MODBUS_ERROR_SERVER_ID_MISMATCH =     {"error": "Error response: ID: 228 Message: Server ID mismatch"}
MODBUS_ERROR_PACKET_LENGTH_ERROR =    {"error": "Error response: ID: 229 Message: Packet length error"}
MODBUS_ERROR_PARAMETER_COUNT_ERROR =  {"error": "Error response: ID: 230 Message: Wrong # of parameters"}
MODBUS_ERROR_PARAMETER_LIMIT_ERROR =  {"error": "Error response: ID: 231 Message: Parameter out of bounds"}
MODBUS_ERROR_REQUEST_QUEUE_FULL =     {"error": "Error response: ID: 232 Message: Request queue full"}
MODBUS_ERROR_ILLEGAL_IP_OR_PORT =     {"error": "Error response: ID: 233 Message: Illegal IP or port"}
MODBUS_ERROR_IP_CONNECTION_FAILED =   {"error": "Error response: ID: 234 Message: IP connection failed"}
MODBUS_ERROR_TCP_HEAD_MISMATCH =      {"error": "Error response: ID: 235 Message: TCP header mismatch"}
MODBUS_ERROR_EMPTY_MESSAGE =          {"error": "Error response: ID: 236 Message: Incomplete request"}
MODBUS_ERROR_UNDEFINED_ERROR =        {"error": "Error response: ID: 255 Message: Unspecified error"}


class SolarDataCollector:
    def __init__(self, host):
        self._host = host
        self._prot = "http"

    def get_data(self):
        return self._get_json("/data")

    def get_ivdata(self):
        return self._get_json("/ivdata")

    def get_sensordata(self):
        return self._get_json("/sensordata")

    def get_info(self):
        return self._get_json()

    def _get_json(self, path = "/"):
        req = requests.get(f"{self._prot}://{self._host}{path}")
        return req.json()
