import threading
import subprocess
from web import Web

from libs.pyftpdlib.authorizers import DummyAuthorizer
from libs.pyftpdlib.handlers import FTPHandler
from libs.pyftpdlib.servers import FTPServer

from constants import CHRONYD_BIN, CHRONYD_CONF, WEB_PORT, WEB_BIND_ADDR, FTP_PORT, FTP_BIND_ADDR
import globals


class ServiceController:
    def __init__(self, settings, db, fs):
        self.settings = settings
        self.db = db
        self.failstore = fs
        self.web = Web(self.settings, self.db, WEB_PORT, WEB_BIND_ADDR)
        self.ftpthread = None
        self.webthread = None
        self.ntp = None

    def start_ftp(self):
        try:
            authorizer = DummyAuthorizer()
            authorizer.add_user(self.settings.get("FTP_USER"), self.settings.get("FTP_PW"), globals.FTP_PATH, perm="elradfmwMT")
            handler = FTPHandler
            handler.authorizer = authorizer
            self.ftpserver = FTPServer((FTP_BIND_ADDR, FTP_PORT), handler)
            self.ftpthread = threading.Thread(target=self.ftpserver.serve_forever)
            self.ftpthread.start()
        except Exception as e:
            self.failstore.add_entry("FTP Service", e)

    def start_web(self):
        self.webthread = threading.Thread(target=self.web.start)
        try:
            self.webthread.start()
        except Exception as e:
            self.failstore.add_entry("Web Service", e)

    def start_ntp(self):
        try:
            self.ntp = subprocess.Popen([CHRONYD_BIN, "-u", "root", "-x", "-d", "-f", CHRONYD_CONF, "-L", "3"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        except Exception as e:
            self.failstore.add_entry("NTP Service", e)

    def start(self):
        if self.settings.get("FTP_ENABLED"):
            self.start_ftp()

        if self.settings.get("WEB_ENABLED"):
            self.start_web()

        if self.settings.get("NTP_ENABLED"):
            self.start_ntp()

    def restart(self):
        if self.settings.get("FTP_ENABLED") and not self.ftpthread:
            self.start_ftp()
        elif not self.settings.get("FTP_ENABLED") and self.ftpthread and self.ftpthread.is_alive():
            self.ftpserver.close_all()
            self.ftpthread = None

        if self.settings.get("WEB_ENABLED") and not self.webthread:
            self.start_web()
        elif not self.settings.get("WEB_ENABLED") and self.webthread and self.webthread.is_alive():
            self.web.stop()
            self.webthread = None

        if self.settings.get("NTP_ENABLED") and not self.ntp:
            self.start_ntp()
        elif not self.settings.get("NTP_ENABLED") and self.ntp and not self.ntp.poll():
            self.ntp.terminate()
            self.ntp = None

    def stop(self):
        if self.ftpthread and self.ftpthread.is_alive():
            self.ftpserver.close_all()

        if self.webthread and self.webthread.is_alive():
            self.web.stop()

        if self.ntp and not self.ntp.poll():
            self.ntp.terminate()
