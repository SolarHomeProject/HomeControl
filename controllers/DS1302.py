from time import sleep
import operator
import RPi.GPIO
import datetime

CLK_PERIOD = 0.00001


class DS1302:
   def __init__(self, sclkpin, cepin, iopin):
      self._RTC_DS1302_SCLK = sclkpin
      self._RTC_DS1302_CE = cepin
      self._RTC_DS1302_IO = iopin
      RPi.GPIO.setwarnings(False)
      RPi.GPIO.setmode(RPi.GPIO.BCM)
      #Initiate DS1302 communication.
      self._InitiateDS1302()
      #Make sure write protect is turned off.
      self._WriteByte(int("10001110", 2))
      self._WriteByte(int("00000000", 2))
      #Make sure trickle charge mode is turned off.
      self._WriteByte(int("10010000", 2))
      self._WriteByte(int("00000000", 2))
      #End DS1302 communication.
      self._EndDS1302()

   #Close Raspberry Pi GPIO use before finishing.
   def stop(self):
      RPi.GPIO.cleanup()

   #Start a transaction with the DS1302 RTC.
   def _InitiateDS1302(self):
      RPi.GPIO.setup(self._RTC_DS1302_SCLK, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.setup(self._RTC_DS1302_CE, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.setup(self._RTC_DS1302_IO, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.output(self._RTC_DS1302_SCLK, 0)
      RPi.GPIO.output(self._RTC_DS1302_IO, 0)
      sleep(CLK_PERIOD)
      RPi.GPIO.output(self._RTC_DS1302_CE, 1)

   #Complete a transaction with the DS1302 RTC.
   def _EndDS1302(self):
      RPi.GPIO.setup(self._RTC_DS1302_SCLK, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.setup(self._RTC_DS1302_CE, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.setup(self._RTC_DS1302_IO, RPi.GPIO.OUT, initial=0)
      RPi.GPIO.output(self._RTC_DS1302_SCLK, 0)
      RPi.GPIO.output(self._RTC_DS1302_IO, 0)
      sleep(CLK_PERIOD)
      RPi.GPIO.output(self._RTC_DS1302_CE, 0)

   #Write a byte of data to the DS1302 RTC.
   def _WriteByte(self, Byte):
      for Count in range(8):
         sleep(CLK_PERIOD)
         RPi.GPIO.output(self._RTC_DS1302_SCLK, 0)

         Bit = operator.mod(Byte, 2)
         Byte = operator.floordiv(Byte, 2)
         sleep(CLK_PERIOD)
         RPi.GPIO.output(self._RTC_DS1302_IO, Bit)

         sleep(CLK_PERIOD)
         RPi.GPIO.output(self._RTC_DS1302_SCLK, 1)

   #Read a byte of data from the DS1302 RTC.
   def _ReadByte(self):
      RPi.GPIO.setup(self._RTC_DS1302_IO, RPi.GPIO.IN, pull_up_down=RPi.GPIO.PUD_DOWN)

      Byte = 0
      for Count in range(8):
         sleep(CLK_PERIOD)
         RPi.GPIO.output(self._RTC_DS1302_SCLK, 1)

         sleep(CLK_PERIOD)
         RPi.GPIO.output(self._RTC_DS1302_SCLK, 0)

         sleep(CLK_PERIOD)
         Bit = RPi.GPIO.input(self._RTC_DS1302_IO)
         Byte |= ((2 ** Count) * Bit)

      return Byte

   #Write date and time to the RTC.
   def WriteDateTime(self, DateTime: datetime):
      #Initiate DS1302 communication.
      self._InitiateDS1302()
      #Write address byte.
      self._WriteByte(int("10111110", 2))
      #Write seconds data.
      self._WriteByte(operator.mod(DateTime.second, 10) | operator.floordiv(DateTime.second, 10) * 16)
      #Write minute data.
      self._WriteByte(operator.mod(DateTime.minute, 10) | operator.floordiv(DateTime.minute, 10) * 16)
      #Write hour data.
      self._WriteByte(operator.mod(DateTime.hour, 10) | operator.floordiv(DateTime.hour, 10) * 16)
      #Write day data.
      self._WriteByte(operator.mod(DateTime.day, 10) | operator.floordiv(DateTime.day, 10) * 16)
      #Write month data.
      self._WriteByte(operator.mod(DateTime.month, 10) | operator.floordiv(DateTime.month, 10) * 16)
      #Write day of week data.
      self._WriteByte(operator.mod(DateTime.weekday(), 10) | operator.floordiv(DateTime.weekday(), 10) * 16)
      #Write year data.
      self._WriteByte(operator.mod(DateTime.year - 2000, 10) | operator.floordiv(DateTime.year - 2000, 10) * 16)
      #Make sure write protect is turned off.
      self._WriteByte(int("00000000", 2))
      #Make sure trickle charge mode is turned off.
      self._WriteByte(int("00000000", 2))
      #End DS1302 communication.
      self._EndDS1302()

   #Read date and time from the RTC.
   def ReadDateTime(self) -> datetime:
      #Initiate DS1302 communication.
      self._InitiateDS1302()
      #Write address byte.
      self._WriteByte(int("10111111", 2))
      #Read date and time data.
      DateTime = {}

      Byte = self._ReadByte()
      DateTime["Second"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10
      Byte = self._ReadByte()
      DateTime["Minute"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10
      Byte = self._ReadByte()
      DateTime["Hour"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10
      Byte = self._ReadByte()
      DateTime["Day"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10
      Byte = self._ReadByte()
      DateTime["Month"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10
      Byte = self._ReadByte()
      #DayOfWeek
      Byte = self._ReadByte()
      DateTime["Year"] = operator.mod(Byte, 16) + operator.floordiv(Byte, 16) * 10 + 2000

      #End DS1302 communication.
      self._EndDS1302()

      #Return as datetime object
      return datetime.datetime(DateTime["Year"], DateTime["Month"], DateTime["Day"], DateTime["Hour"], DateTime["Minute"], DateTime["Second"])

   #Get halted state of the RTC.
   def isHalted(self):
      #Initiate DS1302 communication.
      self._InitiateDS1302()
      #Write address byte.
      self._WriteByte(int("10000001", 2))
      #Read seconds byte
      second = self._ReadByte()

      #End DS1302 communication.
      self._EndDS1302()

      return bool((second & 0b10000000))
