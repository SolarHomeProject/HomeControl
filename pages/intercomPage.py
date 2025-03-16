from PySide2.QtCore import QObject, Slot
import threading
import RPi.GPIO
from time import sleep

from controllers.system import Audio
from controllers.VL53L0X import VL53L0X

from constants import VL53L0X_I2CADDRESS, GPIO_NUM_LOCK_REL, ACARD_EXT_CONTROL_SPEAKER, VOL_STEPS, ACARD_HANDSET, ACARD_DOORSTATION, HANDSET_TAKE_TH
import globals


class intercomPage(QObject):
    def __init__(self, fs):
        QObject.__init__(self)
        self.failstore = fs
        self.audio = Audio()
        self.hsens = VL53L0X(VL53L0X_I2CADDRESS)
        self.io = RPi.GPIO
        self.intercom_active = False

    @Slot()
    def active(self):
        self.hshandler_thread = threading.Thread(target=self.hs_handler)
        self.intercom_active = True
        self.hshandler_thread.start()

    @Slot()
    def inactive(self):
        self.intercom_active = False
        self.audio.stop_intercom()

    def hs_handler(self):
        while self.intercom_active:
            try:
                while self.hsens.get_distance() < HANDSET_TAKE_TH:
                    sleep(1)
                    if not self.intercom_active:
                        return
                self.audio.start_intercom(ACARD_HANDSET, ACARD_DOORSTATION)
                globals.disp_timeout_block = True
                while self.hsens.get_distance() > HANDSET_TAKE_TH:
                    sleep(1)
                    if not self.intercom_active:
                        return
                self.audio.stop_intercom()
                globals.disp_timeout_block = False
            except Exception as e:
                self.failstore.add_entry("Handset", e)

    @Slot(bool)
    def door_open(self, opened):
        self.io.output(GPIO_NUM_LOCK_REL, RPi.GPIO.HIGH if opened else RPi.GPIO.LOW)

    @Slot(str)
    def step_vol_intercom(self, operator):
        self.audio.step_vol(ACARD_DOORSTATION, ACARD_EXT_CONTROL_SPEAKER, VOL_STEPS, operator)

    @Slot(str)
    def step_vol_handset(self, operator):
        self.audio.step_vol(ACARD_HANDSET, ACARD_EXT_CONTROL_SPEAKER, VOL_STEPS, operator)
