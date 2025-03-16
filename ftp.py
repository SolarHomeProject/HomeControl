import threading
from time import sleep
from datetime import datetime
import os

from libs.schedule import Scheduler


class FTPCleanWorker:
    def __init__(self, settings, path):
        self.settings = settings
        self.path = path
        self.scheduler = Scheduler()
        self.update_interval()
        self.scheduler_thread = threading.Thread(target=self.run_scheduler)
        self.running = False
        self.clean_running = False

    def update_interval(self, clear = False):
        if clear:
            self.scheduler.clear()
        self.scheduler.every().day.at(f"{self.settings.get('NIGHT_TIME_RANGE')[1]}:00").do(self.clean_handler)

    def start(self):
        self.running = True
        self.scheduler_thread.start()

    def stop(self):
        while self.clean_running:
            pass
        self.running = False

    def run_scheduler(self):
        self.scheduler.run_all()
        while self.running:
            self.scheduler.run_pending()
            sleep(1)

    def clean_handler(self):
        self.clean_running = True
        now = datetime.now()
        for path, _, files in os.walk(self.path):
            for file in files:
                ftm = datetime.fromtimestamp(os.path.getmtime(os.path.join(path, file)))
                diff = now - ftm
                if diff.days >= 2:
                    os.remove(os.path.join(path, file))
            if path is not self.path and not os.listdir(path):
                os.rmdir(path)
        self.clean_running = False
