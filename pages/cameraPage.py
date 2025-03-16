from PySide2.QtCore import QObject, Slot

import globals


class cameraPage(QObject):
    def __init__(self, settings):
        QObject.__init__(self)
        self.settings = settings

    @Slot(result = str)
    def get_cameraurl(self):
        return self.settings.get("CAMERA_URL")

    @Slot(result = str)
    def get_ftpimgpath(self):
        return globals.FTP_PATH
