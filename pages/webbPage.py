from PySide2.QtCore import QObject, Slot


class webbPage(QObject):
    def __init__(self, settings):
        QObject.__init__(self)
        self.settings = settings

    @Slot(result = "QVariant")
    def get_webb_tabs(self):
        return self.settings.get("WEBB_TABS")

    @Slot(str, str, result = bool)
    def update_webb_tab(self, name, url):
        self.settings.get("WEBB_TABS")[name] = url
        return self.settings.save()

    @Slot(str, str, result = bool)
    def add_webb_tab(self, name, url):
        self.settings.get("WEBB_TABS").update({name: url})
        return self.settings.save()

    @Slot(str, result = bool)
    def del_webb_tab(self, name):
        del self.settings.get("WEBB_TABS")[name]
        return self.settings.save()
