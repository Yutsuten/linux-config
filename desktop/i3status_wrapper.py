#!/usr/bin/env python

import json
import subprocess
import sys


def run_program(args):
    """ Run an arbitrary program. """
    result = subprocess.run(args, text=True, capture_output=True)
    return result.stdout.strip()


def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()


def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

def main():
    """ Inserts extra information into i3status. """
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)

        brightness = '☀ {}%'.format(run_program(['xbacklight', '-get']))
        j.insert(2, {'full_text': brightness, 'name': 'brightness'})

        current_kb = run_program(['xkblayout-state', 'print', '%s'])
        j.insert(4, {'full_text': current_kb, 'name': 'curkb'})

        # and echo back new encoded json
        print_line(prefix+json.dumps(j))


if __name__ == '__main__':
    main()
