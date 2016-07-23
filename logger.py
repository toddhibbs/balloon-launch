from sense_hat import SenseHat
from datetime import datetime
import threading, time, json

sense = SenseHat()
increment = 3
count = 0
max_count = 5000
next_call = time.time()
timestr = time.strftime("%Y%m%d-%H%M%S")
fo = open('data-' + timestr + '.json', 'w', 0)

fo.write('{ "data": [')

def logger():
  global next_call
  global count
  global fo

  data = {}

  next_call = next_call+increment
  if count < max_count:
    threading.Timer( next_call - time.time(), logger ).start()

    if count > 0:
      fo.write(',')

    data['timestamp'] = datetime.now().isoformat('T')
    data['orientation_radians'] = sense.orientation_radians
    data['orientation_degrees'] = sense.orientation
    data['compass'] = sense.compass
    data['compass_raw'] = sense.compass_raw
    data['gyroscope'] = sense.gyroscope
    data['accelerometer'] = sense.accelerometer
    data['temp'] = sense.temp
    data['temp_humidity'] = sense.get_temperature_from_humidity()
    data['temp_pressure'] = sense.get_temperature_from_pressure()
    data['pressure'] = sense.pressure
    data['humidity'] = sense.humidity

    json.dump(data, fo)

  else:
    fo.write(']}')
    fo.close()

  count += 1

logger()
