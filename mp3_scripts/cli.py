import argparse
import os
import sys

from mp3_scripts import __version__
from mp3_scripts import id3_autotag
from mp3_scripts.utils import AppException


def entrypoint():
    try:
        args = id3_autotag.cli()

        if args.mode == 'auto':
            id3_autotag.main(
                directory=args.directory,
                force=args.force,
                compilation=args.compilation,
                eac=args.eac,
                skip_tests=args.skip_tests,
            )

    except AppException as e:
        sys.stderr.write('{}\n'.format(e))
        sys.stderr.flush()
        sys.exit(1)


def parse_command_line():
    parser = argparse.ArgumentParser(description='MP3 tagging & playlist tools')
    subparsers = parser.add_subparsers()

    # setup the shared arguments
    parent_parser = argparse.ArgumentParser(add_help=False)
    parent_parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Display more output')
