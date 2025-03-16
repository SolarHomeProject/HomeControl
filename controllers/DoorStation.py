import usb

REQUEST_TYPE_RECEIVE = usb.util.build_request_type(usb.util.CTRL_IN, usb.util.CTRL_TYPE_CLASS, usb.util.CTRL_RECIPIENT_DEVICE)
USBRQ_HID_GET_REPORT = 0x01
USB_HID_REPORT_TYPE_FEATURE = 0x03


class DoorStation:
    class DoorStationError(Exception):
        pass

    class DeviceNotFoundError(DoorStationError):
        def __repr__(self):
            return "DoorStation Controller Device not found"

    def __init__(self, idVendor, idProduct):
        self._idVendor = idVendor
        self._idProduct = idProduct
        self._device = usb.core.find(idVendor=self._idVendor, idProduct=self._idProduct)

        if not self._device:
            raise DoorStation.DeviceNotFoundError

        #Flush buffer
        while self._transfer(REQUEST_TYPE_RECEIVE, USBRQ_HID_GET_REPORT, 0,  1):
            pass

    #Return true if message is received
    def ringed(self):
        response = self._transfer(REQUEST_TYPE_RECEIVE, USBRQ_HID_GET_REPORT,
                              0, # ignored
                              1) # length

        return True if response else False

    def _transfer(self, request_type, request, index, value):
        return self._device.ctrl_transfer(request_type, request,
                                        (USB_HID_REPORT_TYPE_FEATURE << 8) | 0,
                                         index,
                                         value)

