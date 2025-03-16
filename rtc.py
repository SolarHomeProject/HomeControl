import threading
from time import sleep
from datetime import datetime

from controllers.DS1302 import DS1302

from libs.schedule import Scheduler

from constants import DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN


class RTCWorker:
    def __init__(self):
        self.rtc = DS1302(DS1302_SCLKPIN, DS1302_CEPIN, DS1302_IOPIN)
        self.scheduler = Scheduler()
        self.scheduler.every(1).to(24).hours.do(self.adj_handler)
        self.scheduler_thread = threading.Thread(target=self.run_scheduler)
        self.running = False
        self.adj_running = False

    def start(self):
        self.running = True
        self.scheduler_thread.start()

    def stop(self):
        while self.adj_running:
            pass
        self.running = False

    def run_scheduler(self):
        self.scheduler.run_all()
        while self.running:
            self.scheduler.run_pending()
            sleep(1)

    def adj_handler(self):
        self.adj_running = True
        diff = datetime.now() - self.rtc.ReadDateTime()
        if diff.seconds > 1:
            self.rtc.WriteDateTime(datetime.now())
        self.adj_running = False
