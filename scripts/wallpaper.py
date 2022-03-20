#!/usr/bin/env python
'''
Set wallpaper using xwallpaper.
'''

import argparse
import os
import random
import subprocess
import sys

DIRECTORY = os.path.expanduser('~/Pictures/Wallpapers/Active')
HISTORY_PATH = os.path.expanduser('~/.cache/wallpaper')


def main(**argv):
    '''Main function of wallpaper.py'''
    if argv['random']:
        result = set_random_wallpaper()
    elif argv['restore']:
        result = restore_wallpaper()
    return result


def set_random_wallpaper():
    '''Change to a random wallpaper.'''
    wallpaper_list = os.listdir(DIRECTORY)
    if not wallpaper_list:
        return 1

    if os.path.isfile(HISTORY_PATH):
        with open(HISTORY_PATH, 'r', encoding='utf-8') as history_file:
            history = history_file.read().splitlines()
    else:
        history = []

    while len(history) > len(wallpaper_list) / 2:
        history.pop()

    candidates = set(wallpaper_list) - set(history)
    elected = random.choice(tuple(candidates))
    history.insert(0, elected)
    if len(history) > len(wallpaper_list) / 2 + 1:
        history.pop()

    elected_path = os.path.join(DIRECTORY, elected)
    subprocess.run(['xwallpaper', '--zoom', elected_path], check=True)

    with open(HISTORY_PATH, 'w', encoding='utf-8') as history_file:
        history_file.write('\n'.join(history))
    return 0


def restore_wallpaper():
    '''Restore the last wallpaper used.

    Fallback to a random wallpaper if the last wallpaper is not available.
    '''
    with open(HISTORY_PATH, 'r', encoding='utf-8') as history_file:
        wallpaper = history_file.readline().strip()
    wallpaper_path = os.path.join(DIRECTORY, wallpaper)

    if not os.path.isfile(wallpaper_path):
        return set_random_wallpaper()

    subprocess.run(['xwallpaper', '--zoom', wallpaper_path], check=True)
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Set wallpaper using xwallpaper.')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        '--random', action='store_true',
        help='Change to a random wallpaper.')
    group.add_argument(
        '--restore', action='store_true',
        help='Restore the last wallpaper used.')
    args = parser.parse_args()
    sys.exit(main(**vars(args)))
