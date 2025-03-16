import requests


class Shelly:
    def __init__(self, host):
        self._host = host
        self._prot = "http"

    def get_status(self):
        return self._get_json("/status")

    def get_settings(self):
        return self._get_json("/settings")

    def reset_device_data(self):
        reset_data_dict = {"reset_data": 1}
        return reset_data_dict == self._get_json("/reset_data")

    def _get_json(self, path = "/"):
        req = requests.get(f"{self._prot}://{self._host}{path}")
        return req.json()
