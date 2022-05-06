#!/usr/bin/env python
"""
Get weather information from OpenWeather API and integrate with i3blocks.
"""

import json
import os
import sys
import time

import requests
from urllib3.util.retry import Retry


WEATHER_API = 'https://api.openweathermap.org/data/2.5/weather'


def main():
    """Write current temperature to /tmp/weather file."""
    required_vars = ['OPEN_WEATHER_KEY', 'OPEN_WEATHER_LAT', 'OPEN_WEATHER_LON']
    missing_vars = [var for var in required_vars if var not in os.environ]

    if missing_vars:
        msg = 'Missing {} environment variable(s).\n'
        sys.stderr.write(msg.format(','.join(missing_vars)))
        return 1

    use_cache = False
    now = time.time()

    if os.path.isfile('/tmp/openweather'):
        with open('/tmp/openweather', 'r', encoding='utf-8') as openweather:
            weather = json.loads(openweather.read())
        if weather['timestamp'] + 600 > now:
            use_cache = True

    if not use_cache:
        weather = get_current_weather(
            os.environ['OPEN_WEATHER_KEY'],
            os.environ['OPEN_WEATHER_LAT'],
            os.environ['OPEN_WEATHER_LON'],
        )
        weather['timestamp'] = now
        with open('/tmp/openweather', 'w', encoding='utf-8') as openweather:
            openweather.write(json.dumps(weather))

    sunrise = weather['sys']['sunrise']
    sunset = weather['sys']['sunset']
    twilight = 1200
    if sunrise - twilight <= now <= sunrise + twilight:
        weather_status = ['🌅']
    elif sunset - twilight <= now <= sunset + twilight:
        weather_status = ['🌇']
    elif sunrise <= now <= sunset:
        weather_status = ['☀️']
    else:
        weather_status = ['🌙']
    weather_status += [
        f'{round(weather["main"]["temp"])}°C',
        f'💧{weather["main"]["humidity"]}%',
    ]

    print(' '.join(weather_status))
    return 0


def get_current_weather(key, lat, lon):
    """Get current weather using the OpenWeather API."""
    params = {
        'lat': lat,
        'lon': lon,
        'units': 'metric',
        'appid': key,
    }
    with requests.Session() as session:
        session.mount('https://', requests.adapters.HTTPAdapter(
            max_retries=Retry(total=5, backoff_factor=2)
        ))
        response = session.get(WEATHER_API, params=params)
    return response.json()


if __name__ == '__main__':
    sys.exit(main())