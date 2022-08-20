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
        if now < weather['timestamp'] + 900:
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

    # https://openweathermap.org/weather-conditions
    icon_map = {
        '01d': '☀️', '01n': '🌙',
        '02d': '⛅️', '02n': '🌙',
        '03d': '☁️', '03n': '☁️',
        '04d': '☁️', '04n': '☁️',
        '09d': '🌧️', '09n': '🌧️',
        '10d': '🌦️', '10n': '',
        '11d': '⛈️', '11n': '⛈️',
        '13d': '❄️', '13n': '❄️',
        '50d': '🌫', '50n': '🌫',
    }

    icon = icon_map[weather['weather'][0]['icon']]
    tooltip = [
        f'💧{weather["main"]["humidity"]}%',
        f'🎏 {weather["wind"]["speed"]}m/s',
        f'☁️ {weather["clouds"]["all"]}%',
    ]
    if 'rain' in weather:
        tooltip.append(f'☔ {weather["rain"]["1h"]}mm (1h)')
    if 'snow' in weather:
        tooltip.append(f'☃️ {weather["snow"]["1h"]}mm (1h)')

    print(json.dumps({
        'text': f'{icon} {round(weather["main"]["temp"])}°C',
        'tooltip': '  '.join(tooltip),
    }))
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
