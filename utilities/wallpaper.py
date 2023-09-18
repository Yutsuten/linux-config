#!/usr/bin/env python
"""Set wallpaper in sway."""

from __future__ import annotations

import argparse
import os
import random
import subprocess
import sys
from pathlib import Path
from typing import Literal

WALLPAPERS_PATH = Path.expanduser(Path('~/Pictures/Wallpapers'))
HISTORY_FILE_PATH = Path.expanduser(Path('~/.cache/wallpaper'))


def main(**argv: bool) -> Literal[0, 1]:
    """Main function."""
    if argv['random']:
        return set_random_wallpaper()
    if argv['restore']:
        return restore_wallpaper()
    return 1


def set_wallpaper(wallpaper_path: Path) -> None:
    """Set wallpaper to specified image."""
    try:
        subprocess.run(
            ['/usr/bin/swaymsg', 'output', '*', 'bg', wallpaper_path, 'fill'],  # noqa: S603
            check=True,
        )
    except subprocess.CalledProcessError:
        print('Failed to apply wallpaper. Sway is not running.')  # noqa: T201


def set_random_wallpaper() -> Literal[0, 1]:
    """Change to a random wallpaper."""
    wallpapers = os.listdir(WALLPAPERS_PATH)
    wallpapers = [wallpaper for wallpaper in wallpapers if Path.is_file(WALLPAPERS_PATH / Path(wallpaper))]
    if not wallpapers:
        return 1

    if Path.is_file(HISTORY_FILE_PATH):
        with Path.open(HISTORY_FILE_PATH, 'r', encoding='utf-8') as history_file:
            history = history_file.read().splitlines()
    else:
        history = []

    while len(history) > len(wallpapers) / 2:
        history.pop()

    candidates = set(wallpapers) - set(history)
    elected = random.choice(tuple(candidates))  # noqa: S311
    history.insert(0, elected)
    if len(history) > len(wallpapers) / 2 + 1:
        history.pop()

    with Path.open(HISTORY_FILE_PATH, 'w', encoding='utf-8') as history_file:
        history_file.write('\n'.join(history))

    wallpaper_path = WALLPAPERS_PATH / Path(elected)
    set_wallpaper(wallpaper_path)
    return 0


def restore_wallpaper() -> Literal[0, 1]:
    """Restore the last wallpaper used.

    Fallback to a random wallpaper if the last wallpaper is not available.
    """
    if not Path.is_file(HISTORY_FILE_PATH):
        return set_random_wallpaper()

    with Path.open(HISTORY_FILE_PATH, 'r', encoding='utf-8') as history_file:
        wallpaper = history_file.readline().strip()
    wallpaper_path = WALLPAPERS_PATH / Path(wallpaper)

    if not Path.is_file(wallpaper_path):
        return set_random_wallpaper()

    set_wallpaper(wallpaper_path)
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Set wallpaper in sway.')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--random', action='store_true', help='Change to a random wallpaper.')
    group.add_argument('--restore', action='store_true', help='Restore the last wallpaper used.')
    args = parser.parse_args()
    sys.exit(main(**vars(args)))
