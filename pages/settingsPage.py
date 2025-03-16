from PySide2.QtCore import QObject, Signal, Slot
from datetime import datetime
import threading
import apt
import apt.progress.base
import subprocess
import psutil
import platform
import NetworkManager
import ipaddress
import requests
import os

from controllers.DS1302 import DS1302
from controllers.system import DisplayController
from controllers.system import Audio
from controllers.system import Storage, STORAGE_INTERNAL_DRIVE
from controllers.system import Network
from controllers.system import Thermal

from constants import DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN, ACARD_HANDSET, ACARD_DOORSTATION, ACARD_EXT_CONTROL_SPEAKER, ACARD_EXT_CONTROL_MIC, ACARD_INT_CONTROL_SPEAKER, ACARD_HDMI, NETIF_ETH, NETIF_WIFI, APP_VER, DEFAULT_DATA_REFRESH_RATE, DEFAULT_DB_DATA_INSERT_RATE, DEFAULT_NIGHT_TIME_RANGE, DEFAULT_DISPLAY_TIMEOUT
import globals


class APTProgressMonitor(apt.progress.base.AcquireProgress):
    def __init__(self, signal):
        apt.progress.base.AcquireProgress.__init__(self)
        self.aptprogress = signal

    def pulse(self, owner):
        apt.progress.base.AcquireProgress.pulse(self, owner)
        percent = (((self.current_bytes + self.current_items) * 100.0) / float(self.total_bytes + self.total_items))
        current_item = self.current_items + 1
        self.aptprogress.emit(f"DL_RUNNING {current_item} {self.total_items}", int(percent))

    def fail(self, item):
        if item.owner.status is not item.owner.STAT_DONE:
            self.aptprogress.emit(f"FETCHFAIL {item.shortdesc} {item.owner.error_text}", 0)

    def done(self, item=None):
        self.aptprogress.emit("DL_COMPLETE", 100)

    def fetch(self, item):
        if not item.owner.complete:
            self.aptprogress.emit(f"ITEMFETCH {item.shortdesc}", -1)

    def stop(self):
        apt.progress.base.AcquireProgress.stop(self)
        self.aptprogress.emit("DL_STOP", 100)

    def start(self):
        apt.progress.base.AcquireProgress.start(self)
        self.aptprogress.emit("DL_START", 0)

class APTInstallMonitor(apt.progress.base.InstallProgress):
    def __init__(self, signal):
        apt.progress.base.InstallProgress.__init__(self)
        self.aptinstall = signal
        self.last = 0.0
        self.hc_updated = False

    def start_update(self):
        self.aptinstall.emit("UPD_START", 0)

    def finish_update(self):
        self.aptinstall.emit("UPD_FIN", 100)

    def error(self, pkg, errormsg):
        self.aptinstall.emit(f"INSTALLFAIL {pkg} {errormsg}", 0)

    def status_change(self, pkg, percent, status):
        self.aptinstall.emit(f"STATECHANGE {pkg} {status}", percent)

    def dpkg_status_change(self, pkg, status):
        self.aptinstall.emit(f"STATECHANGE {pkg} {status}", -1)

    def processing(self, pkg, stage):
        if pkg == "homecontrol":
            self.hc_updated = True
        self.aptinstall.emit(f"PKG_PROCESS {pkg} {stage}", -1)

    def update_interface(self):
        apt.progress.base.InstallProgress.update_interface(self)
        self.aptinstall.emit(self.status, int(self.percent))
        self.last = self.percent

class APTOpMonitor(apt.progress.base.OpProgress):
    def __init__(self, signal):
        apt.progress.base.OpProgress.__init__(self)
        self.aptop = signal

    def update(self, percent=None):
        apt.progress.base.OpProgress.update(self, percent)
        self.aptop.emit(f"STATECHANGE {self.op}", self.percent)

    def done(self):
        apt.progress.base.OpProgress.done(self)
        self.aptop.emit("DONE", 100)

class settingsPage(QObject):
    def __init__(self, settings, db, dbworker, sc, ftpclean, rtcworker):
        QObject.__init__(self)
        self.settings = settings
        self.db = db
        self.dbworker = dbworker
        self.servicecontroller = sc
        self.ftpclean = ftpclean
        self.rtcworker = rtcworker
        self.rtc = DS1302(DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN)
        self.display = DisplayController()
        self.audio = Audio()
        self.storage = Storage()
        self.net = Network(NETIF_ETH)
        self.wifi = Network(NETIF_WIFI)
        NetworkManager.NetworkManager.OnStateChanged(self.get_network_data)
        self.net.OnIFStateChanged(self.get_network_data)
        self.wifi.OnIFStateChanged(self.get_network_data)
        self.therm = Thermal()
        self.aptpm = APTProgressMonitor(self.aptprogress)
        self.aptim = APTInstallMonitor(self.aptinstall)
        self.aptom = APTOpMonitor(self.aptop)

    datadisplay = Signal(int, int, arguments = ["timeout", "brightness_level"])
    dataaudio = Signal(int, int, int, int, int, arguments = ["handset_speaker_vol", "handset_mic_vol", "doorstation_speaker_vol", "doorstation_mic_vol", "internal_vol"])
    datastorage = Signal("QVariant", arguments = ["disk_info"])
    datanetwork = Signal(bool, bool, bool, bool, bool, bool, "QVariant", "QVariant", bool, arguments = ["ethup", "wifiup", "ethactive", "wifiactive", "ethok", "wifiok", "ethparams", "wifiparams", "inetok"])
    dataapi = Signal(str, str, str, str, arguments = ["SHELLY_HOST", "SDC_HOST", "SWSC_HOST", "CAMERA_URL"])
    autoconfig_api_status = Signal("QVariant")
    dataupdate = Signal(str, str, str, arguments = ["app_ver", "hcos_ver", "kernel_ver"])
    updatedone = Signal()
    datasystem = Signal(int, int, "QVariantList", bool, str, str, bool, str, bool, arguments = ["DATA_REFRESH_RATE", "DB_DATA_INSERT_RATE", "NIGHT_TIME_RANGE", "FTP_ENABLED", "FTP_USER", "FTP_PW", "WEB_ENABLED", "WEB_PW", "NTP_ENABLED"])
    datainfo = Signal(str, str, str, str, float, float, arguments = ["throttled_state", "int_temp", "rtc_time", "local_time", "cpu_percent", "mem_percent"])
    wifiscanresult = Signal(str, int, arguments = ["ssid", "rsnflags"])
    error = Signal(str)

    aptprogress = Signal(str, int, arguments = ["status", "progress_val"])
    aptinstall = Signal(str, int, arguments = ["status", "progress_val"])
    aptop = Signal(str, int, arguments = ["status", "progress_val"])
    apterr = Signal(str)

    @Slot()
    def active(self):
        self.data_thread = threading.Thread(target=self.get_data)
        self.data_thread.start()

    def get_data(self):
        try:
            self.datadisplay.emit(self.settings.get("DISPLAY_TIMEOUT"), self.display.get_brightness_level())
            self.dataaudio.emit(self.audio.get_vol(ACARD_HANDSET, ACARD_EXT_CONTROL_SPEAKER), self.audio.get_vol(ACARD_HANDSET, ACARD_EXT_CONTROL_MIC), self.audio.get_vol(ACARD_DOORSTATION, ACARD_EXT_CONTROL_SPEAKER), self.audio.get_vol(ACARD_DOORSTATION, ACARD_EXT_CONTROL_MIC), self.audio.get_vol(ACARD_HDMI, ACARD_INT_CONTROL_SPEAKER))
            disk_data = {}
            for disk in self.storage.get_physical_drives(True):
                disk_data[disk] = {"parts": self.storage.get_partitions(disk), "size": self.storage.get_disk_size(disk), "internal": True if disk == STORAGE_INTERNAL_DRIVE else False}
            self.datastorage.emit(disk_data)
            self.get_network_data()
            self.dataapi.emit(self.settings.get("SHELLY_HOST"), self.settings.get("SDC_HOST"), self.settings.get("SWSC_HOST"), self.settings.get("CAMERA_URL"))
            self.dataupdate.emit(APP_VER, open("/etc/os-release").read().split("=")[4].split("\n")[0].strip('"'), platform.release())
            self.datasystem.emit(self.settings.get("DATA_REFRESH_RATE"), self.settings.get("DB_DATA_INSERT_RATE"), self.settings.get("NIGHT_TIME_RANGE"), self.settings.get("FTP_ENABLED"), self.settings.get("FTP_USER"), self.settings.get("FTP_PW"), self.settings.get("WEB_ENABLED"), self.settings.get("WEB_PW"), self.settings.get("NTP_ENABLED"))
            self.datainfo.emit(self.therm.get_throttled(), self.therm.measure_temp(), self.rtc.ReadDateTime().strftime("%d.%m.%Y %H:%M"), datetime.now().strftime("%d.%m.%Y %H:%M"), psutil.cpu_percent(), psutil.virtual_memory().percent)
            for ap in self.wifi.scan():
                self.wifiscanresult.emit(ap.Ssid, ap.RsnFlags)
        except Exception as errorStr:
            self.error.emit(repr(errorStr))

    def get_network_data(self, *args, **kwargs):
        self.datanetwork.emit(self.net.get_interface_up(), self.wifi.get_interface_up(), self.net.get_interface_active(), self.wifi.get_interface_active(), self.net.get_interface_upandrunning(), self.wifi.get_interface_upandrunning(), self.net.get_network_params(), self.wifi.get_network_params(), NetworkManager.NetworkManager.State == NetworkManager.NM_STATE_CONNECTED_GLOBAL)

    @Slot(int, int)
    def set_display(self, timeout, brightness_level):
        self.settings.setsave("DISPLAY_TIMEOUT", timeout)
        self.display.set_brightness(brightness_level)

    @Slot(int, int, int, int, int)
    def set_audio(self, handset_speaker_vol, handset_mic_vol, doorstation_speaker_vol, doorstation_mic_vol, internal_vol):
        self.audio.set_vol(ACARD_HANDSET, ACARD_EXT_CONTROL_SPEAKER, handset_speaker_vol)
        self.audio.set_vol(ACARD_HANDSET, ACARD_EXT_CONTROL_MIC, handset_mic_vol)
        self.audio.set_vol(ACARD_DOORSTATION, ACARD_EXT_CONTROL_SPEAKER, doorstation_speaker_vol)
        self.audio.set_vol(ACARD_DOORSTATION, ACARD_EXT_CONTROL_MIC, doorstation_mic_vol)
        self.audio.set_vol(ACARD_HDMI, ACARD_INT_CONTROL_SPEAKER, internal_vol)

    @Slot(str, str, str, str, str, str)
    def set_network(self, ethip, ethsm, wifiip, wifism, router, dns):
        self.net.set_network_settings(ethip, ethsm)
        self.wifi.set_network_settings(wifiip, wifism, router, dns)

    @Slot(str, str)
    def set_network_wifidhcp(self, ethip, ethsm):
        self.net.set_network_settings(ethip, ethsm)
        self.wifi.set_network_settings_dhcp()
        self.get_network_data()

    @Slot()
    def wifi_scan(self):
        for ap in self.wifi.scan():
            self.wifiscanresult.emit(ap.Ssid, ap.RsnFlags)

    @Slot(str, str)
    def wifi_connect(self, ssid, pw):
        self.wifi.connect_wifi(ssid, pw)
        self.get_network_data()

    @Slot(str, str, str, str)
    def set_api(self, SHELLY_HOST, SDC_HOST, SWSC_HOST, CAMERA_URL):
        self.settings.set("SHELLY_HOST", SHELLY_HOST)
        self.settings.set("SDC_HOST", SDC_HOST)
        self.settings.set("SWSC_HOST", SWSC_HOST)
        self.settings.set("CAMERA_URL", CAMERA_URL)
        self.settings.save()

    @Slot()
    def autoconfig_api(self):
        def run():
            sdc_host = None
            swsc_host = None
            shelly_host = None

            network = self.net.get_network_params()
            ipnet = ipaddress.IPv4Network(f"{network['addr']}/{network['netmask']}", False)

            for ip in ipnet:
                if not ip == ipnet.network_address and not ip == ipnet.broadcast_address:
                    try:
                        req = requests.get(f"http://{ip}/")
                        data = req.json()

                        if "Device_Name" in data.keys():
                            if data["Device_Name"] == "SolarDataCollector":
                                sdc_host = str(ip)
                                self.autoconfig_api_status.emit(data)
                                if swsc_host:
                                    break
                            elif data["Device_Name"] == "SolarWaterStorageController":
                                swsc_host = str(ip)
                                self.autoconfig_api_status.emit(data)
                                if sdc_host:
                                    break
                    except:
                        continue

            for ip in ipnet:
                if not ip == ipnet.network_address and not ip == ipnet.broadcast_address:
                    try:
                        req = requests.get(f"http://{ip}/settings")
                        data = req.json()

                        if "device" in data.keys():
                            if "type" in data["device"].keys():
                                if data["device"]["type"] == "SHEM-3":
                                    shelly_host = str(ip)
                                    self.autoconfig_api_status.emit({"Device_Name": data["device"]["type"], "IP": data["wifi_sta"]["ip"], "FW_VERSION": data["fw"], "Uptime": "-"})
                                    break
                    except:
                        continue

            self.dataapi.emit(shelly_host or "", sdc_host or "", swsc_host or "", "")
        threading.Thread(target=run).start()

    @Slot(int, int, int, int)
    def set_system(self, DATA_REFRESH_RATE, DB_DATA_INSERT_RATE, NIGHT_TIME_RANGE_FROM, NIGHT_TIME_RANGE_TO):
        self.settings.set("DATA_REFRESH_RATE", DATA_REFRESH_RATE)
        self.settings.set("DB_DATA_INSERT_RATE", DB_DATA_INSERT_RATE)
        self.settings.set("NIGHT_TIME_RANGE", (NIGHT_TIME_RANGE_TO, NIGHT_TIME_RANGE_FROM))
        self.dbworker.update_interval(True)
        self.ftpclean.update_interval(True)
        self.settings.save()

    @Slot(bool, str, str, bool, str, bool)
    def set_system_services(self, FTP_ENABLED, FTP_USER, FTP_PW, WEB_ENABLED, WEB_PW, NTP_ENABLED):
        self.settings.set("FTP_ENABLED", FTP_ENABLED)
        self.settings.set("FTP_USER", FTP_USER)
        self.settings.set("FTP_PW", FTP_PW)
        self.settings.set("WEB_ENABLED", WEB_ENABLED)
        self.settings.set("WEB_PW", WEB_PW)
        self.settings.set("NTP_ENABLED", NTP_ENABLED)
        self.settings.save()
        self.servicecontroller.restart()

    def shutdown_handler(self):
        self.dbworker.stop()
        self.db.close()
        self.servicecontroller.stop()
        self.ftpclean.stop()
        self.rtcworker.stop()

    @Slot(str)
    def system_action(self, action):
        if action == "shutdown":
            self.shutdown_handler()
            subprocess.Popen(["/usr/sbin/poweroff"])
        elif action == "reboot":
            self.shutdown_handler()
            subprocess.Popen(["/usr/sbin/reboot"])
        elif action == "sysreset":
            self.reset_system()
            subprocess.Popen(["/usr/sbin/reboot"])

    @Slot()
    def run_systemupd(self):
        def run():
            reboot_required = False
            globals.disp_timeout_block = True
            try:
                self.aptop.emit("CACHE_INS", 0)
                cache = apt.Cache(progress = self.aptom)
                self.aptop.emit("CACHE_UPDATE", 0)
                cache.update(fetch_progress = self.aptpm)
                self.aptop.emit("CACHE_OPEN", 0)
                cache.open(progress = self.aptom)
                self.aptop.emit("CACHE_UPGRADE", 0)
                cache.upgrade()
                self.aptop.emit("CACHE_COMMIT", 0)
                cache.commit(fetch_progress = self.aptpm, install_progress = self.aptim)
                if self.aptim.hc_updated or os.path.isfile("/var/run/reboot-required"):
                    reboot_required = True
            except Exception as errorStr:
                self.apterr.emit(repr(errorStr))
            finally:
                if reboot_required:
                    self.updatedone.emit()
                globals.disp_timeout_block = False
        threading.Thread(target=run).start()

    @Slot()
    def setup_done(self):
        self.settings.setsave("FIRSTRUN", False)
        self.system_action("reboot")

    @Slot()
    def reset_system(self):
        self.shutdown_handler()
        self.settings.clear()
        self.settings.set("DATA_REFRESH_RATE", DEFAULT_DATA_REFRESH_RATE)
        self.settings.set("DB_DATA_INSERT_RATE", DEFAULT_DB_DATA_INSERT_RATE)
        self.settings.set("NIGHT_TIME_RANGE", DEFAULT_NIGHT_TIME_RANGE)
        self.settings.set("DISPLAY_TIMEOUT", DEFAULT_DISPLAY_TIMEOUT)
        self.settings.set("FIRSTRUN", True)
        self.settings.save()
        self.net.set_network_settings_dhcp(False)
        self.wifi.set_network_settings_dhcp(False)
        self.wifi.connect_wifi("_", "")
        self.set_audio(100, 100, 100, 100, 100)
        os.remove(globals.DB_FILE)
        for path, _, files in os.walk(globals.FTP_PATH):
            for file in files:
                os.remove(os.path.join(path, file))
            if path is not globals.FTP_PATH and not os.listdir(path):
                os.rmdir(path)
