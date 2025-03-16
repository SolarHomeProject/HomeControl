#!/usr/bin/python3

from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWebEngine import QtWebEngine
from PySide2.QtCore import QObject, Signal, Slot
from datetime import datetime
import sys
import os
import env
import subprocess
import RPi.GPIO
import dbus.mainloop.glib
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
from NetworkManager import NetworkManager, NM_STATE_CONNECTED_GLOBAL

from db import DBWorker
from failstore import FailStore
from services import ServiceController
from ftp import FTPCleanWorker
from rtc import RTCWorker

from controllers.DS1302 import DS1302
from controllers.system import Storage

from libs.EasySettings import EasySettings
from libs.tinyflux import TinyFlux

from pages.boilerPage import boilerPage
from pages.cameraPage import cameraPage
from pages.energyPage import energyPage
from pages.homePage import homePage
from pages.intercomPage import intercomPage
from pages.mainPage import mainPage
from pages.settingsPage import settingsPage
from pages.solarPage import solarPage
from pages.webbPage import webbPage

from constants import QML_MAIN, QML_ERROR, QML_FIRSTRUN, HC_CONFIG, DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN, GPIO_NUM_DISPDEC, GPIO_NUM_DISPINC, GPIO_NUM_DISPPWR, GPIO_NUM_LOCK_REL, GPIO_NUM_EXTBELL, EXT_DISK_MOUNTPOINT, EXT_ROOT, DEFAULT_DATA_REFRESH_RATE, DEFAULT_DB_DATA_INSERT_RATE, DEFAULT_NIGHT_TIME_RANGE, DEFAULT_DISPLAY_TIMEOUT
import globals


def set_gpio_states():
    RPi.GPIO.setwarnings(False)
    RPi.GPIO.setmode(RPi.GPIO.BCM)
    RPi.GPIO.setup(GPIO_NUM_LOCK_REL, RPi.GPIO.OUT)
    RPi.GPIO.setup(GPIO_NUM_EXTBELL, RPi.GPIO.OUT)
    RPi.GPIO.setup(GPIO_NUM_DISPINC, RPi.GPIO.IN)
    RPi.GPIO.setup(GPIO_NUM_DISPPWR, RPi.GPIO.IN)
    RPi.GPIO.setup(GPIO_NUM_DISPDEC, RPi.GPIO.IN)

def set_clock():
    rtc = DS1302(DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN)

    if rtc.isHalted():
        rtc.WriteDateTime(datetime.now())

    if not NetworkManager.State == NM_STATE_CONNECTED_GLOBAL:
        subprocess.call(["timedatectl", "set-ntp", "false"])
        dt = rtc.ReadDateTime()
        subprocess.call(["timedatectl", "set-time", dt.strftime("%Y-%m-%d %H:%M:%S")])
    else:
        subprocess.call(["timedatectl", "set-ntp", "true"])

def mount_storage():
    global fs

    storage = Storage()
    mounted = False
    try:
        for drive in storage.get_physical_drives():
            for part in storage.get_partitions(drive):
                storage.mount_drive(f"/dev/{part}", EXT_DISK_MOUNTPOINT, "ext4", "rw")
                mounted = True
                break

        if not mounted:
            fs.add_entry("Storage", "No external storage could be found/mounted.", warning = True)
        else:
            if not os.path.isdir(os.path.join(EXT_DISK_MOUNTPOINT, "data")):
                os.mkdir(os.path.join(EXT_DISK_MOUNTPOINT, "data"))
            if not os.path.isdir(os.path.join(EXT_DISK_MOUNTPOINT, "data", "db")):
                os.mkdir(os.path.join(EXT_DISK_MOUNTPOINT, "data", "db"))
            if not os.path.isdir(os.path.join(EXT_DISK_MOUNTPOINT, "data", "ftp")):
                os.mkdir(os.path.join(EXT_DISK_MOUNTPOINT, "data", "ftp"))
            globals.update_data(EXT_ROOT)
    except Exception as e:
        fs.add_entry("Storage", e, warning = True)

def init_app():
    global app
    global settings
    global db
    global dbworker
    global sc
    global fs
    global ftpclean
    global rtcworker

    QtWebEngine.initialize()
    app = QApplication()
    engine = QQmlApplicationEngine()

    settingspage = settingsPage(settings, db, dbworker, sc, ftpclean, rtcworker)
    engine.rootContext().setContextProperty("settingsbackend", settingspage)

    if not settings.has_option("FIRSTRUN") or settings.get("FIRSTRUN"):
        engine.load(QML_FIRSTRUN)
        sys.exit(app.exec_())
    else:
        boilerpage = boilerPage(settings, db)
        camerapage = cameraPage(settings)
        energypage = energyPage(settings, db)
        homepage = homePage(settings, db)
        intercompage = intercomPage(fs)
        mainpage = mainPage(settings, fs)
        solarpage = solarPage(settings, db)
        webbpage = webbPage(settings)

        dbworker.start()
        sc.start()
        ftpclean.start()
        rtcworker.start()

        engine.rootContext().setContextProperty("boilerbackend", boilerpage)
        engine.rootContext().setContextProperty("camerabackend", camerapage)
        engine.rootContext().setContextProperty("energybackend", energypage)
        engine.rootContext().setContextProperty("homebackend", homepage)
        engine.rootContext().setContextProperty("intercombackend", intercompage)
        engine.rootContext().setContextProperty("mainbackend", mainpage)
        engine.rootContext().setContextProperty("solarbackend", solarpage)
        engine.rootContext().setContextProperty("webbbackend", webbpage)

        engine.load(QML_MAIN)
        sys.exit(app.exec_())

app = None
fs = FailStore()
try:
    set_gpio_states()
    set_clock()
    mount_storage()

    settings = EasySettings(HC_CONFIG)
    if not settings.has_option("DATA_REFRESH_RATE"):
        settings.set("DATA_REFRESH_RATE", DEFAULT_DATA_REFRESH_RATE)
    if not settings.has_option("DB_DATA_INSERT_RATE"):
        settings.set("DB_DATA_INSERT_RATE", DEFAULT_DB_DATA_INSERT_RATE)
    if not settings.has_option("NIGHT_TIME_RANGE"):
        settings.set("NIGHT_TIME_RANGE", DEFAULT_NIGHT_TIME_RANGE)
    if not settings.has_option("DISPLAY_TIMEOUT"):
        settings.set("DISPLAY_TIMEOUT", DEFAULT_DISPLAY_TIMEOUT)
    db = TinyFlux(globals.DB_FILE, auto_index = False)
    dbworker = DBWorker(settings, db, fs)
    sc = ServiceController(settings, db, fs)
    ftpclean = FTPCleanWorker(settings, globals.FTP_PATH)
    rtcworker = RTCWorker()

    init_app()
except Exception as e:
    if not app:
        app = QApplication()
    engine = QQmlApplicationEngine()

    class Backend(QObject):
        error = Signal(str)
        def __init__(self, errormsg):
            QObject.__init__(self)
            self.errormsg = errormsg

        @Slot()
        def printError(self): self.error.emit(self.errormsg)

        @Slot()
        def reboot(self): subprocess.Popen(["/usr/sbin/reboot"])

    b = Backend(repr(e))
    engine.rootContext().setContextProperty("backend", b)

    engine.load(QML_ERROR)
    sys.exit(app.exec_())
