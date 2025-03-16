class FailStore:
    def __init__(self):
        self.failstore = {}
        self.haserror = False
        self.changed_callback = None

    def get(self):
        return self.failstore

    def add_entry(self, type, exception, warning = False):
        if isinstance(exception, str):
            error = exception
        else:
            error = repr(exception)
            if hasattr(exception, "message"):
                error = exception.message
            elif hasattr(exception, "strerror"):
                error = exception.strerror

        if not error in self.failstore:
            self.failstore[error] = type
            if not warning:
                self.haserror = True

            if self.changed_callback:
                self.changed_callback()

    def del_entry(self, exception):
        del self.failstore[exception]

        if self.changed_callback:
            self.changed_callback()

    def clear(self):
        self.failstore = {}
        self.haserror = False

        if self.changed_callback:
            self.changed_callback()

    def OnChanged(self, callback_func):
        self.changed_callback = callback_func
