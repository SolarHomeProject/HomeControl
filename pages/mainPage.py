from PySide2.QtCore import QObject, Signal, Slot
import RPi.GPIO
import threading
from operator import add, sub
from NetworkManager import NetworkManager, NM_STATE_CONNECTED_GLOBAL
from gi.repository import GLib
from time import sleep

from controllers.DoorStation import DoorStation
from controllers.system import DisplayController
from controllers.system import Audio
from controllers.system import Network

from constants import NETIF_ETH, NETIF_WIFI, DOORSTATION_IDVENDOR, DOORSTATION_IDPRODUCT, GPIO_NUM_DISPDEC, GPIO_NUM_DISPINC, GPIO_NUM_DISPPWR, GPIO_NUM_EXTBELL, GPIO_BUT_BOUNCETIME, DISP_BRIGHTNESS_STEPS, DOORBELL_WAV, ACARD_DOORSTATION, ACARD_HDMI
import globals


class mainPage(QObject):
    def __init__(self, settings, fs):
        QObject.__init__(self)
        self.settings = settings
        self.failstore = fs
        self.failstore.OnChanged(self.fs_changed)
        self.doorstation = DoorStation(DOORSTATION_IDVENDOR, DOORSTATION_IDPRODUCT)
        self.display = DisplayController()
        self.audio = Audio()
        self.audio2 = Audio()
        self.net = Network(NETIF_ETH)
        self.wifi = Network(NETIF_WIFI)
        NetworkManager.OnStateChanged(self.nm_statechange)
        self.net.OnIFStateChanged(self.nm_statechange)
        self.wifi.OnIFStateChanged(self.nm_statechange)
        self.io = RPi.GPIO
        self.io.add_event_detect(GPIO_NUM_DISPDEC, self.io.FALLING, bouncetime = GPIO_BUT_BOUNCETIME, callback = self.dispdec_handler)
        self.io.add_event_detect(GPIO_NUM_DISPINC, self.io.FALLING, bouncetime = GPIO_BUT_BOUNCETIME, callback = self.dispinc_handler)
        self.io.add_event_detect(GPIO_NUM_DISPPWR, self.io.FALLING, bouncetime = GPIO_BUT_BOUNCETIME, callback = self.disptog_handler)
        self.nm_thread = threading.Thread(target=GLib.MainLoop().run)
        self.nm_thread.start()
        self.dshandler_thread = threading.Thread(target=self.ds_handler)
        self.dshandler_thread.start()

    noerror = Signal()
    error = Signal()
    warning = Signal()
    htok = Signal()
    hterror = Signal()
    htwarning = Signal()
    inetok = Signal()
    ineterror = Signal()
    wifiok = Signal()
    wifidisconnected = Signal()
    wifierror = Signal()
    wifiwarning = Signal()
    dispevt = Signal(bool)
    fsdata = Signal("QVariant")

    @Slot()
    def active(self):
        self.fs_changed()
        self.nm_statechange()

    def nm_statechange(self, *args, **kwargs):
        if self.net.get_interface_upandrunning():
            self.htok.emit()
        elif self.net.get_interface_up() or self.net.get_interface_active():
            self.htwarning.emit()
        else:
            self.hterror.emit()

        if NetworkManager.State == NM_STATE_CONNECTED_GLOBAL:
            self.inetok.emit()
        else:
            self.ineterror.emit()

        if self.wifi.get_interface_upandrunning():
            self.wifiok.emit()
        elif not self.wifi.get_connected():
            self.wifidisconnected.emit()
        elif self.wifi.get_interface_up() or self.wifi.get_interface_active():
            self.wifiwarning.emit()
        else:
            self.wifierror.emit()

    def fs_changed(self):
        if self.failstore.get() and self.failstore.haserror:
            self.error.emit()
        elif self.failstore.get():
            self.warning.emit()
        else:
            self.noerror.emit()
        self.fsdata.emit(self.failstore.get())

    def dispdec_handler(self, channel):
        self.display.step_brightness(DISP_BRIGHTNESS_STEPS, sub)

    def dispinc_handler(self, channel):
        self.display.step_brightness(DISP_BRIGHTNESS_STEPS, add)

    def disptog_handler(self, channel):
        self.dispevt.emit(False)
        self.display.toggle_power()

    @Slot()
    def disp_off_timeout(self):
        self.dispevt.emit(False)
        self.display.set_power(False)

    @Slot(result = int)
    def get_display_timeout(self):
        return self.settings.get("DISPLAY_TIMEOUT") * 1000

    @Slot(result = bool)
    def get_disp_timeout_block(self):
        return globals.disp_timeout_block

    @Slot(str)
    def del_fs_entry(self, entry):
        self.failstore.del_entry(entry)

    def ds_handler(self):
        while True:
            try:
                while not self.doorstation.ringed():
                    sleep(0.5)
                if not self.display.get_power_state():
                    self.display.set_power(True)
                self.dispevt.emit(True)
                while self.doorstation.ringed():
                    sleep(0.01)
                    self.audio.play_wav(ACARD_HDMI, DOORBELL_WAV)
                    self.audio2.play_wav(ACARD_DOORSTATION, DOORBELL_WAV)
                    self.io.output(GPIO_NUM_EXTBELL, self.io.HIGH)
                self.audio.stop_playback()
                self.audio2.stop_playback()
                self.io.output(GPIO_NUM_EXTBELL, self.io.LOW)
            except Exception as e:
                self.failstore.add_entry("DoorStation", e)
