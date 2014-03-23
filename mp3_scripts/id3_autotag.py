#! /usr/bin/env python

from __future__ import absolute_import

import argparse
import datetime
import fnmatch
import os
import sys

from eyed3 import core, id3

from .utils import AppException


def main(directory=None, compilation=False, force=True, eac=False, skip_tests=False, quiet=False):
    # remove (Disc 1) from album

    if directory is None:
        directory = os.getcwd()

    directory_name = os.path.basename(directory)
    parts = directory_name.split(' - ')
    if len(parts) != 3:
        raise AppException('Badly formed directory name')

    artist = parts[0]
    year = parts[1]
    album = parts[2]

    # in compilation mode, artist will vary per track
    album_artist = artist

    # clean '(Disc *)' from album name; don't want it in ID3 tag
    if '(Disc' in album:
        # TODO test
        album = album[0:album.find('(Disc')]

    # list all files in target directory
    files = os.listdir(directory) 

    # count mp3's for track total
    total_num_tracks = len(fnmatch.filter(files, '*.mp3'))

    # load genre types / image types ?
    # TODO import pdb; pdb.set_trace()

    # iterate MP3s in target directory
    for filename in fnmatch.filter(files, '*.mp3'):
        # split the mp3's filename into track and title
        parts = os.path.splitext(filename)[0].split(' - ')
        track_num = parts[0]
        title = parts[1]

        #if compilation:
            # extract ARTIST

        # extract GENRE
        # if GENRE:
            # validate GENRE

        if os.path.exists(os.path.join(directory, 'folder.jpg')):
            # extract existing 'FRONT_COVER' image
            # check new/existing has largest height
            # set largest as folder.jpg
            image = True

        # load the file into eyed3
        audiofile = core.load(os.path.join(directory, filename))

        # force removal of existing tag
        if force is True and audiofile.tag is not None:
            id3.Tag.remove(audiofile.path, id3.ID3_ANY_VERSION)

        if audiofile.tag is None:
            audiofile.initTag(id3.ID3_V2_4)

        # set some tags
        audiofile.tag.artist = unicode(artist)
        audiofile.tag.album_artist = unicode(album_artist)
        audiofile.tag.album = unicode(album)
        audiofile.tag.title = unicode(title)
        audiofile.tag.track_num = (track_num, total_num_tracks)
        audiofile.tag.recording_date = core.Date(int(year))
        audiofile.tag.tagging_date = '{:%Y-%m-%d}'.format(datetime.datetime.now())

        # set a tag to say this was ripped with EAC
        if eac is True:
            audiofile.tag.user_text_frames.set(u'EAC', u'Ripping Tool')

        # write a cover art image
        if image is True:
            with open(os.path.join(directory, 'folder.jpg'), 'rb') as f:
                audiofile.tag.images.set(
                    type=id3.frames.ImageFrame.FRONT_COVER,
                    img_data=f.read(),
                    mime_type='image/jpeg',
                )

        # save the tag
        audiofile.tag.save(
            version=id3.ID3_V2_4,
            encoding='utf8',
            preserve_file_time=True,
        )

        if quiet is False:
            from eyed3.plugins.classic import ClassicPlugin
            classic.printTag(audiofile.tag)

        # run eyeD3 test suite


def cli():
    parser = argparse.ArgumentParser(description='MP3 tagging & playlist tools')
    subparsers = parser.add_subparsers()

    # setup the shared arguments
    parent_parser = argparse.ArgumentParser(add_help=False)
    parent_parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Display more output')
    parent_parser.add_argument(
        '--quiet', '-q', action='store_true',
        help='Display no output')

    # setup parser for backup command
    ptag = subparsers.add_parser('auto',
        parents=[parent_parser],
        help='Autotag all MP3s in this directory',
    )
    ptag.set_defaults(mode='auto')
    ptag.add_argument(
        '--directory', '-d',
        help='Album directory (defaults to cwd)')
    ptag.add_argument(
        '--force', '-f', action='store_true',
        help='Force removal of all existings tags')
    ptag.add_argument(
        '--compilation', '-c', action='store_true',
        help='directory contains a compilation')
    ptag.add_argument(
        '--eac', action='store_true',
        help='Set EAC as ripping tool in USER frame')
    ptag.add_argument(
        '--skip-tests', action='store_true',
        help='Skip eyeD3 test suite')

    args = parser.parse_args()

    return args
