#!/usr/bin/env python

"""Update media metadata using ffmpeg."""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def parse_args(args: list) -> argparse.Namespace:
    """Parse command line options."""
    parser = argparse.ArgumentParser(
        epilog='''You can set global and stream metadata.
        Ex: ffmeta title=GlobalTitle 0 title=Stream0Title 1 title=Stream1Title
        input.webp''',
    )
    parser.add_argument('-c', '--clear', help='clear metadata', action='store_true')
    parser.add_argument('-C', '--cover', help='add cover to music file', type=str)
    parser.add_argument('-q', '--quiet', help='do not output metadata comparison', action='store_true')
    parser.add_argument('-x', '--delete', help='delete generated file', action='store_true')
    parser.add_argument('metadata', type=str, nargs='*')
    parser.add_argument('media_file', type=str)
    return parser.parse_args(args)

def ffprobe(media_file: str) -> None:
    """Print media metadata with ffprobe."""
    p = subprocess.run(['ffprobe', media_file], capture_output=True, check=True)
    result = p.stderr.decode().splitlines()
    while not result[0].startswith('Input'):
        result.pop(0)
    result.pop(0)
    print('\n'.join(result))

def main(argv) -> int:
    """Main function of ffmeta."""
    args = parse_args(argv)
    media_path = Path(args.media_file)

    ffmpeg_command = ['ffmpeg', '-loglevel', 'warning', '-i', args.media_file]
    if args.cover:
        ffmpeg_command += ['-i', args.cover, '-metadata:s:1', 'comment=Cover (front)']
        if media_path.suffix == '.mp3':
            ffmpeg_command += ['-codec', 'copy']
        elif media_path.suffix == '.opus':
            ffmpeg_command += ['-acodec', 'copy', '-vcodec', 'theora', '-q:v', '10']
        else:
            print('Unsupported file. Cannot add cover.')
            return 1
    else:
        ffmpeg_command += ['-codec', 'copy']

    if args.clear:
        ffmpeg_command += ['-map_metadata', '-1', '-map_metadata:s', '-1']

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
    if args.cover:
        ffmpeg_command += ['-map', '0', '-map', '1']

    ffmpeg_command += ['-y', new_media_file]
    subprocess.run(ffmpeg_command, check=True)

    if not args.quiet:
        print('Before:')
        ffprobe(args.media_file)
        print('\nAfter:')
        ffprobe(new_media_file)

    if args.delete:
        if not args.quiet:
            print('\nRemoving updated file...')
        Path(new_media_file).unlink()
    else:
        shutil.move(new_media_file, args.media_file)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
