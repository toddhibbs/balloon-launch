from sense_hat import SenseHat
from datetime import datetime
import threading, time, json

sense = SenseHat()
increment = 3
count = 0
max_count = 5000
next_call = time.time()
timestr = time.strftime("%Y%m%d-%H%M%S")
fo = open('data-' + timestr + '.csv', 'w', 0)

header = ['timestamp','orientation_radians','orientation_degrees','compass','compass_raw','gyroscope','accelerometer','temp','temp_humidity','temp_pressure','pressure','humidity'];
fo.write(','.join(header))

def logger():
  global next_call
  global count
  global fo

  next_call = next_call+increment
  if count < max_count:
    threading.Timer( next_call - time.time(), logger ).start()


    data = [
      datetime.now().isoformat('T'),
      sense.orientation_radians,
      sense.orientation,
      sense.compass,
      sense.compass_raw,
      sense.gyroscope,
      sense.accelerometer,
      sense.temp,
      sense.get_temperature_from_humidity(),
      sense.get_temperature_from_pressure(),
      sense.pressure,
      sense.humidity
    ]
    fo.write(','.join(map(str, data)))

    # data['timestamp'] = datetime.now().isoformat('T')
    # data['orientation_radians'] = sense.orientation_radians
    # data['orientation_degrees'] = sense.orientation
    # data['compass'] = sense.compass
    # data['compass_raw'] = sense.compass_raw
    # data['gyroscope'] = sense.gyroscope
    # data['accelerometer'] = sense.accelerometer
    # data['temp'] = sense.temp
    # data['temp_humidity'] = sense.get_temperature_from_humidity()
    # data['temp_pressure'] = sense.get_temperature_from_pressure()
    # data['pressure'] = sense.pressure
    # data['humidity'] = sense.humidity


  else:
    fo.close()

  count += 1

logger()
