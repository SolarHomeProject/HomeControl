import os

os.environ["QT_QPA_PLATFORM"] = "eglfs"
os.environ["QT_QPA_EGLFS_HIDECURSOR"] = "1"
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
