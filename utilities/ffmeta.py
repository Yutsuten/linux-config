#!/usr/bin/env python

"""Update media metadata using ffmpeg."""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def ffprobe(media_file: str) -> None:
    """Print media metadata with ffprobe."""
    p = subprocess.run(['ffprobe', media_file], capture_output=True, check=True)
    result = p.stderr.decode().splitlines()
    while not result[0].startswith('Input'):
        result.pop(0)
    result.pop(0)
    print('\n'.join(result))


def main() -> int:
    """Main function of ffmeta."""
    parser = argparse.ArgumentParser(
        epilog='''You can set global and stream metadata.
        Ex: ffmeta title=GlobalTitle 0 title=Stream0Title 1 title=Stream1Title
        input.ogg''',
    )
    parser.add_argument('-y', help='override original file', action='store_true')
    parser.add_argument('metadata', type=str, nargs='+')
    parser.add_argument('media_file', type=str)
    args = parser.parse_args()

    ffmpeg_command = ['ffmpeg', '-i', args.media_file, '-codec', 'copy']
    stream = 'g'

    while args.metadata:
        arg = args.metadata.pop(0)
        if arg.isdigit():
            stream = arg
            break
        ffmpeg_command += ['-metadata:g', arg]

    while args.metadata:
        arg = args.metadata.pop(0)
        if arg.isdigit():
            stream = arg
            continue
        ffmpeg_command += [f'-metadata:s:{stream}', arg]

    new_media_file = f'new_{args.media_file}'
    ffmpeg_command += ['-y', new_media_file]
    subprocess.run(ffmpeg_command, stderr=subprocess.DEVNULL, check=True)

    print('Before:')
    ffprobe(args.media_file)
    print('\nAfter:')
    ffprobe(new_media_file)

    if args.y:
        shutil.move(new_media_file, args.media_file)
    else:
        print('\nRemoving updated file...')
        Path(new_media_file).unlink()
    return 0

if __name__ == '__main__':
    sys.exit(main())
