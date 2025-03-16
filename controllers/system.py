import subprocess
import smbus2
from time import sleep
from glob import glob
from os.path import basename, dirname
from os import strerror
import ctypes, ctypes.util
import netifaces
import ipaddress
import NetworkManager

DDC_VCP_BUS = 20
DDC_VCP_CODE_POWER_MODE = 0xd6
DDC_VCP_CODE_BRIGHTNESS = 0x10
DDC_VCP_CODE_SPEAKER_VOL = 0x62
DDC_VCP_HOST_SLAVE_ADDRESS = 0x51
DDC_VCP_PROTOCOL_FLAG = 0x80
DDC_VCP_COMMAND_READ = 0x01
DDC_VCP_REPLY_READ = 0x02
DDC_VCP_COMMAND_WRITE = 0x03
DDC_VCP_DDCCI_ADDR = 0x37
DDC_VCP_READ_DELAY = DDC_VCP_WRITE_DELAY = 0.06

STORAGE_INTERNAL_DRIVE = "mmcblk0"

HW_THERMAL_STATES = \
{
"0x1" : "Under-voltage detected",
"0x2" : "Arm frequency capped",
"0x4" : "Currently throttled",
"0x8" : "Soft temperature limit active",
"0x10000" : "Under-voltage has occurred",
"0x20000" : "Arm frequency capping has occurred",
"0x40000" : "Throttling has occurred",
"0x80000" : "Soft temperature limit has occurred"
}


class DisplayController:
    def __init__(self):
        self._bus = smbus2.SMBus(DDC_VCP_BUS)

    class ReadException(Exception):
        pass

    def set_power(self, state):
        self._write(DDC_VCP_CODE_POWER_MODE, 1 if state else 5)

    def toggle_power(self):
        if self.get_power_state():
            self.set_power(False)
        else:
            self.set_power(True)

    def set_brightness(self, val):
        self._write(DDC_VCP_CODE_BRIGHTNESS, val)

    def step_brightness(self, steps, operator):
        level = operator(self.get_brightness_level(), steps)
        self._write(DDC_VCP_CODE_BRIGHTNESS, level if level >= 0 else 0)

    def set_speaker_vol(self, val):
        self._write(DDC_VCP_CODE_SPEAKER_VOL, val)

    def get_power_state(self):
        return self._read(DDC_VCP_CODE_POWER_MODE) == 1

    def get_brightness_level(self):
        return self._read(DDC_VCP_CODE_BRIGHTNESS)

    def get_speaker_vol(self):
        return self._read(DDC_VCP_CODE_SPEAKER_VOL)

    def _write(self, ctrl, value):
        payload = self._prepare_payload(DDC_VCP_DDCCI_ADDR, [DDC_VCP_COMMAND_WRITE, ctrl, (value >> 8) & 255, value & 255])
        self._write_payload(payload)

    def _read(self, ctrl):
        payload = self._prepare_payload(DDC_VCP_DDCCI_ADDR, [DDC_VCP_COMMAND_READ, ctrl])
        self._write_payload(payload)

        sleep(DDC_VCP_READ_DELAY)

        if self._bus.read_byte(DDC_VCP_DDCCI_ADDR) != DDC_VCP_DDCCI_ADDR << 1:
            raise DisplayController.ReadException("ACK invalid")

        data_length = self._bus.read_byte(DDC_VCP_DDCCI_ADDR) & ~DDC_VCP_PROTOCOL_FLAG
        data = [self._bus.read_byte(DDC_VCP_DDCCI_ADDR) for n in range(data_length)]
        checksum = self._bus.read_byte(DDC_VCP_DDCCI_ADDR)

        xor = (DDC_VCP_DDCCI_ADDR << 1 | 1) ^ DDC_VCP_HOST_SLAVE_ADDRESS ^ (DDC_VCP_PROTOCOL_FLAG | len(data))

        for n in data:
            xor ^= n

        if xor != checksum:
            raise DisplayController.ReadException("Invalid checksum")

        if data[0] != DDC_VCP_REPLY_READ:
            raise DisplayController.ReadException("Invalid response type")

        if data[2] != ctrl:
            raise DisplayController.ReadException("Received data for unrequested control")

        return data[6] << 8 | data[7]

    def _write_payload(self, payload):
        self._bus.write_i2c_block_data(DDC_VCP_DDCCI_ADDR, payload[0], payload[1:])

    def _prepare_payload(self, addr, data):
        payload = [DDC_VCP_HOST_SLAVE_ADDRESS, DDC_VCP_PROTOCOL_FLAG | len(data)]

        if data[0] == DDC_VCP_COMMAND_READ:
            xor = addr << 1 | 1
        else:
            xor = addr << 1

        payload.extend(data)

        for x in payload:
            xor ^= x

        payload.append(xor)

        return payload

class Audio:
    def __init__(self):
        self._running = False
        self._running_intercom = False
        self._arecord1 = None
        self._aplay1 = None
        self._arecord2 = None
        self._aplay2 = None
        self._aplayfile = None

    def start_intercom(self, audiodev1, audiodev2):
        if not self._running_intercom:
            self._arecord1 = subprocess.Popen(["arecord", "--buffer-time=40", "-f", "cd", f"--device=sysdefault:{audiodev1}", "-"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            self._aplay1 = subprocess.Popen(["aplay", "--buffer-time=40", f"--device=sysdefault:{audiodev2}", "-"], stdin=self._arecord1.stdout, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


            self._arecord2 = subprocess.Popen(["arecord", "--buffer-time=40", "-f", "cd", f"--device=sysdefault:{audiodev2}", "-"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            self._aplay2 = subprocess.Popen(["aplay", "--buffer-time=40", f"--device=sysdefault:{audiodev1}", "-"], stdin=self._arecord2.stdout, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            if not self._arecord1.poll() and not self._aplay1.poll() and not self._arecord2.poll() and not self._aplay2.poll():
                self._running_intercom = True

    def stop_intercom(self):
        if self._running_intercom:
            self._arecord1.kill()
            self._aplay1.kill()
            self._arecord2.kill()
            self._aplay2.kill()

            sleep(0.1)

            if self._arecord1.poll() and self._aplay1.poll() and self._arecord2.poll() and self._aplay2.poll():
                self._running_intercom = False

    def play_wav(self, device, file):
        if self._aplayfile is None or self._aplayfile.poll() is not None:
            self._aplayfile = subprocess.Popen(["aplay", f"--device=sysdefault:{device}", file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        if not self._aplayfile.poll():
            self._running = True

    def stop_playback(self):
        if self._running:
            self._aplayfile.kill()

            sleep(0.1)

            if self._aplayfile.poll:
                self._running = False

    def playback_running(self):
        return self._aplayfile.poll() is None

    def set_vol(self, device, control, level):
        subprocess.check_call(["amixer", f"--device=sysdefault:{device}", "sset", control, f"{level}%"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def step_vol(self, device, control, steps, operator):
        subprocess.check_call(["amixer", f"--device=sysdefault:{device}", "sset", control, f"{steps}%{operator}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def get_vol(self, device, control):
        output = subprocess.check_output(["amixer", f"--device=sysdefault:{device}", "get", control], stderr=subprocess.DEVNULL).decode()
        for line in output.splitlines():
            if line.startswith("  Front Left:") or line.startswith("  Front Right:") or line.startswith("  Mono: Playback"):
                return int(line.split(" [", 1)[1].split("] ", 1)[0][:-1])
        raise OSError(f"Device {device} with control {control} not found")

class Storage:
    def __init__(self):
        self._libc = ctypes.CDLL(ctypes.util.find_library('c'), use_errno=True)
        self._libc.mount.argtypes = (ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_ulong, ctypes.c_char_p)

    def get_physical_drives(self, internal = False):
        return [basename(dirname(d)) for d in glob("/sys/block/*/device") if not (not internal and STORAGE_INTERNAL_DRIVE in d)]

    def get_partitions(self, disk):
        return [basename(dirname(p)) for p in glob(f"/sys/block/{disk}/*/start")]

    def get_disk_size(self, disk):
        return round(int(open(f"/sys/block/{disk}/size", "r").read()) * 512 / 1000 / 1000 / 1000, 1)

    def mount_drive(self, source, target, fs, options=''):
      ret = self._libc.mount(source.encode(), target.encode(), fs.encode(), 0, options.encode())
      if ret < 0:
        errno = ctypes.get_errno()
        raise OSError(errno, f"Error mounting {source} ({fs}) on {target} with options '{options}': {strerror(errno)}")

class Network:
    def __init__(self, interface):
        self._interface = interface
        self._nm_device = NetworkManager.NetworkManager.GetDeviceByIpIface(self._interface)

    def get_interface_up(self):
        if open(f"/sys/class/net/{self._interface}/operstate", "r").read().strip() == "up":
            return True
        else:
            return False

    def get_interface_active(self):
        return netifaces.AF_INET in netifaces.ifaddresses(self._interface)

    def get_interface_upandrunning(self):
        return self.get_interface_up() and self.get_interface_active()

    def get_network_params(self):
        ifparams = {}
        try:
            ifparams = netifaces.ifaddresses(self._interface)[netifaces.AF_INET][0]
            gw = netifaces.gateways()["default"][netifaces.AF_INET][0]
            dns = open("/etc/resolv.conf", "r").read().split("\n")[1].split(" ")[1]
            conn_settings = self._nm_device.GetAppliedConnection(0)[0]
            ifparams["dhcp"] = True if conn_settings['ipv4']['method'] == "auto" else False
            ifparams["gw"] = gw
            ifparams["dns"] = dns
        except:
            conn = self._get_nm_iface_conn()
            conn_settings = conn.GetSettings()
            try:
                ifparams["dhcp"] = True if conn_settings["ipv4"]["method"] == "auto" else False
                address_data = conn_settings["ipv4"]["address-data"][0]
                ifparams = {"addr": address_data["address"], "netmask": str(ipaddress.IPv4Network(f"{address_data['address']}/{address_data['prefix']}", strict=False).netmask)}
                try:
                    ifparams["gw"] = conn_settings["ipv4"]["gateway"]
                    ifparams["dns"] = conn_settings["ipv4"]["dns"]
                except:
                    ifparams["gw"] = ""
                    ifparams["dns"] = ""
            except:
                ifparams["addr"] = ""
                ifparams["netmask"] = ""
                ifparams["gw"] = ""
                ifparams["dns"] = ""
        return ifparams

    def set_network_settings(self, ip, sm, router = None, dns = None, try_apply = True):
        ip_network = ipaddress.IPv4Network((ip, sm), False).compressed
        prefix = int(ip_network.split('/')[1])
        conn = self._get_nm_iface_conn()
        conn_settings = conn.GetSettings()

        conn_settings["ipv4"]["method"] = "manual"
        conn_settings["ipv4"]["addresses"] = [[ip, prefix, router or "0.0.0.0"]]
        conn_settings["ipv4"]["address-data"] = [{"address": ip, "prefix": prefix}]
        if router:
            conn_settings["ipv4"]["gateway"] = router
        if dns:
            conn_settings["ipv4"]["dns"] = [dns]

        conn.Update(conn_settings)
        if try_apply:
            try:
                self._nm_device.Reapply(conn_settings, 0, 0)
            except:
                pass

    def set_network_settings_dhcp(self, try_apply = True):
        conn = self._get_nm_iface_conn()
        conn_settings = conn.GetSettings()

        conn_settings['ipv4']['method'] = "auto"
        conn_settings['ipv4']['addresses'] = []
        conn_settings['ipv4']['address-data'] = []
        conn_settings['ipv4'].pop("gateway", None)
        conn_settings['ipv4'].pop("dns", None)
        conn_settings['ipv4'].pop("dns-data", None)

        conn.Update(conn_settings)
        if try_apply:
            try:
                self._nm_device.Reapply(conn_settings, 0, 0)
            except:
                pass

    def get_connected(self):
        if self._nm_device.DeviceType != NetworkManager.NM_DEVICE_TYPE_WIFI:
            return

        for connection in NetworkManager.NetworkManager.ActiveConnections:
            if connection.Type == '802-11-wireless':
                return True
        return False

    def scan(self):
        if self._nm_device.DeviceType != NetworkManager.NM_DEVICE_TYPE_WIFI:
            return

        self._nm_device.RequestScan({})
        return self._nm_device.GetAllAccessPoints()

    def connect_wifi(self, ssid, pw):
        if self._nm_device.DeviceType != NetworkManager.NM_DEVICE_TYPE_WIFI:
            return

        conn = self._get_nm_iface_conn()
        conn_settings = conn.GetSettings()
        conn.Delete()

        conn_settings["802-11-wireless"]["ssid"] = ssid
        if pw:
            conn_settings["802-11-wireless"]["security"] = "802-11-wireless-security"
            conn_settings["802-11-wireless-security"] = {"auth-alg": "open", "key-mgmt": "wpa-psk", "psk": pw}
        else:
            conn_settings["802-11-wireless"].pop("security", None)
            conn_settings.pop("802-11-wireless-security", None)

        NetworkManager.NetworkManager.AddAndActivateConnection(conn_settings, self._nm_device, "/")

    def OnIFStateChanged(self, handler_func):
        self._nm_device.OnStateChanged(handler_func)

    def _get_nm_iface_conn(self):
        for conn in NetworkManager.Settings.ListConnections():
            if conn.GetSettings()["connection"]["interface-name"] == self._interface:
                return conn

class Thermal:
    def get_throttled(self):
        state = self._get_vcgencmd_output("get_throttled")
        if state in HW_THERMAL_STATES:
            return HW_THERMAL_STATES[state]
        else:
            return False

    def measure_temp(self):
        return self._get_vcgencmd_output("measure_temp")

    def _get_vcgencmd_output(self, cmd):
        return subprocess.check_output(["vcgencmd", cmd], stderr=subprocess.DEVNULL).decode().strip().split("=")[1]
