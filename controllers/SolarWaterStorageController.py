import requests

TEMP_DEVICE_DISCONNECTED_C = -127
SETTING_ACCEPT_CODE = 202

DEVICE_MODES = {
    0: "Disabled",
    1: "Solar-Charge",
    2: "Night-Charge",
    3: "Day-Charge"
}


class SolarWaterStorageController:
    def __init__(self, host):
        self._host = host
        self._prot = "http"

    def get_status(self):
        return self._get_json("/status")

    def get_settings(self):
        return self._get_json("/settings")

    def get_info(self):
        return self._get_json()

    def set_inverter_url(self, inverter_url):
        return self._get_with_params("/settings", f"inverterurl={inverter_url}") == SETTING_ACCEPT_CODE

    def set_shelly_url(self, shelly_url):
        return self._get_with_params("/settings", f"shellyurl={shelly_url}") == SETTING_ACCEPT_CODE

    def set_maxwattsout(self, maxwattsout):
        return self._get_with_params("/settings", f"max_watts_out={maxwattsout}") == SETTING_ACCEPT_CODE

    def set_solarmaxout(self, solarmaxout):
        return self._get_with_params("/settings", f"solar_max_out={solarmaxout}") == SETTING_ACCEPT_CODE

    def set_water_target_temp(self, target_temp):
        return self._get_with_params("/settings", f"water_t_temp={target_temp}") == SETTING_ACCEPT_CODE

    def set_device_mode(self, mode):
        return self._get_with_params("/settings", f"device_mode={mode}") == SETTING_ACCEPT_CODE

    def clear_failstore(self):
        return self._get_with_params("/settings", "failstore=clear") == SETTING_ACCEPT_CODE

    def _get_json(self, path = "/"):
        while True:
            try:
                req = requests.get(f"{self._prot}://{self._host}{path}")
                break
            except requests.exceptions.ConnectionError:
                continue
        return req.json()

    def _get_with_params(self, path, params):
        while True:
            try:
                req = requests.get(f"{self._prot}://{self._host}{path}?{params}")
                break
            except requests.exceptions.ConnectionError:
                continue
        return req.status_code
