#!/usr/bin/env python
"""A i3status wrapper to output custom commands to it."""

import json
import subprocess
import sys


def main():
    """Inserts extra information into i3status."""
    print_line(read_line())
    print_line(read_line())
    while True:
        line, prefix = read_line(), ''
        if line.startswith(','):
            line, prefix = line[1:], ','

        status = json.loads(line)

        current_kb = run_program(['xkblayout-state', 'print', '%s'])
        status.insert(6, {'full_text': current_kb, 'name': 'curkb'})

        print_line(prefix+json.dumps(status))


def run_program(args):
    """Run an arbitrary program."""
    result = subprocess.run(args, text=True, check=True, capture_output=True)
    return result.stdout.strip()


def print_line(message):
    """Non-buffered printing to stdout."""
    sys.stdout.write(message + '\n')
    sys.stdout.flush()


def read_line():
    """Interrupted respecting reader for stdin."""
    try:
        line = sys.stdin.readline().strip()
        if not line:
            sys.exit(3)
        return line
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == '__main__':
    main()
