#!/usr/bin/env python3

import argparse
import os
import re
import sys
import typing as t


def confirm(msg: str, default: t.Optional[bool] = None) -> bool:
    if default is None:
        msg += ' [y/n]'
    else:
        msg += ' [Y/n]' if default else ' [y/N]'

    variants = {
        'y': True,
        'n': False,
    }

    while 1:
        answer = input(f'{msg}: ').lower()

        try:
            return variants[answer]
        except KeyError:
            if not answer and default is not None:
                return default


def match_files(pattern, path) -> t.Iterator[str]:
    """
    Returns an iterator of filenames in a directory that match the regular expression pattern.
    """
    for filename in sorted(os.listdir(path=path)):
        if pattern.match(filename):
            yield os.path.abspath(os.path.join(path, filename))


def map_files(pattern, repl, files: t.Iterable[str]) -> t.Iterator[t.Tuple[str, str]]:    
    for src in files:
        if os.path.isfile(src):
            target = os.path.join(
                os.path.dirname(src),
                pattern.sub(repl, os.path.basename(src))
            )
            yield src, target


def main() -> int:
    args = parse_args()
    
    print('Pattern: ', args.pattern)
    
    map_names = list(map_files(
        args.pattern, args.repl, match_files(args.pattern, args.path)
    ))
    
    if not map_names:
        print('No files matching the pattern were found.')
        return 0
    
    for src, target in map_names:
        print('%s => %s' % (
            os.path.basename(src),
            os.path.basename(target)
        ))
    
    if confirm('Rename all files?', False):
        for src, target in map_names:
            if not os.path.exists(target) or confirm(f'File {target!r} exists, rename?', False):
                os.rename(src, target)

    return 0
    

def parse_args():
    parser = argparse.ArgumentParser(
        description='Rename files in directories whose names match the regular expression pattern.',
        prog='rename',
    )
    parser.add_argument(
        'pattern',
        type=lambda v: re.compile(rf'^{v}$', re.I),
        help='Regular expression to match filename.'
    )
    parser.add_argument(
        'repl',
        help='The new filename. Subtemplate references are supported.'
    )
    parser.add_argument(
        'path',
        nargs='?',
        default='.',
        help='The directory in which to search.',
    )
    return parser.parse_args()


if __name__ == '__main__':
    sys.exit(main())
