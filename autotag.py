import argparse
import datetime
import fnmatch
import os

import eyed3
from eyed3 import core, id3
from eyed3 import LOCAL_ENCODING
from eyed3.plugins import load, LoaderPlugin
from eyed3.plugins.classic import ClassicPlugin
from eyed3.utils.console import printMsg, printError, printWarning, boldText

eyed3.require((0, 7))

class AutotagPlugin(LoaderPlugin):
    SUMMARY = u'Autotag files based on their filename and the parent directory name'
    DESCRIPTION = u"""
Description here
"""
    NAMES = ['autotag']

    def __init__(self, arg_parser):
        super(AutotagPlugin, self).__init__(arg_parser)
        g = self.arg_group

        self.meta = None

        def UnicodeArg(arg):
            return unicode(arg, LOCAL_ENCODING)

        # CLI options
        g.add_argument('-f', '--force', action='store_true', # dest='force',
                       help=ARGS_HELP['--force'])
        g.add_argument('-c', '--compilation', action='store_true', # dest='compilation',
                       help=ARGS_HELP['--compilation'])
        g.add_argument('-G', '--genre', type=UnicodeArg,# dest='genre',
                       help=ARGS_HELP['--genre'])
        g.add_argument('-E', '--eac', type=UnicodeArg,# dest='eac',
                       help=ARGS_HELP['--eac'])
        g.add_argument('--skip-tests', type=UnicodeArg,# dest='skip_tests',
                       help=ARGS_HELP['--skip-tests'])
        g.add_argument('-v', '--verbose', action='store_true',
                       help=ARGS_HELP['--verbose'])


    def handleFile(self, f):
        super(AutotagPlugin, self).handleFile(f)

        if len(self.args.paths) != 1:
            printError('Autotag operates on only a single album at a time')
            return

        # extract album metadata from directory name
        if self.meta is None:
            if self.args.paths[0] == '.':
                path = os.getcwd()
            else:
                path = self.args.paths[0]

            self.parseDirectoryName(path)

        if not self.audio_file:
            if os.path.basename(f) != 'folder.jpg':
                printWarning('Unknown type: {}'.format(os.path.basename(f)))
        else:
            self.tagFile(os.path.basename(f))

    def tagFile(self, filename):
        parts = os.path.splitext(filename)[0].split(' - ')
        track_num = parts[0]
        title = parts[1]

        #if compilation:
            # extract ARTIST

        # extract GENRE
        # if GENRE:
            # validate GENRE

        # load the file into eyed3
        #audiofile = core.load(os.path.join(directory, filename))

        # force removal of existing tag
        if self.args.force is True and self.audio_file.tag is not None:
            id3.Tag.remove(self.audio_file.path, id3.ID3_ANY_VERSION)
            printMsg("Tag removed from '{}'".format(filename))

        if self.audio_file.tag is None:
            self.audio_file.initTag(id3.ID3_V2_4)

        # set some tags
        self.audio_file.tag.artist = unicode(self.meta['artist'])
        self.audio_file.tag.album_artist = unicode(self.meta['album_artist'])
        self.audio_file.tag.album = unicode(self.meta['album'])
        self.audio_file.tag.title = unicode(title)
        self.audio_file.tag.track_num = (track_num, self.meta['total_num_tracks'])
        self.audio_file.tag.recording_date = core.Date(self.meta['year'])
        self.audio_file.tag.tagging_date = '{:%Y-%m-%d}'.format(datetime.datetime.now())

        # set a tag to say this was ripped with EAC
        if self.args.eac is True:
            self.audio_file.tag.user_text_frames.set(u'EAC', u'Ripping Tool')

        # write a cover art image
        if self.meta['image'] is not None:
            self.audio_file.tag.images.set(
                type=id3.frames.ImageFrame.FRONT_COVER,
                img_data=self.meta['image'],
                mime_type='image/jpeg',
            )

        # save the tag
        #self.audio_file.tag.save(
        #    version=id3.ID3_V2_4,
        #    encoding='utf8',
        #    preserve_file_time=True,
        #)

        classic = load('classic')
        import pdb;pdb.set_trace()

        fakeArgs = argparse.Namespace(
            quiet=self.args.quiet,
            verbose=self.args.verbose,
            write_images_dir=False,
            write_objects_dir=False,
        )
        ClassicPlugin.printAudioInfo(fakeArgs, self.audio_file.info)
        ClassicPlugin.printTag(fakeArgs, self.audio_file.info)

        #import pdb;pdb.set_trace()
        #classic.printTag(audiofile.tag)
        print self.audio_file.info


    def parseDirectoryName(self, path):
        # verify directory name structure
        directory_name = os.path.basename(path)
        parts = directory_name.split(' - ')
        if len(parts) != 3:
            # check directory contains mp3s..
            if len(fnmatch.filter(os.listdir(path), '*.mp3')) == 0:
                printError("No MP3s found in '{}'".format(directory_name))
            else:
                printError("Badly formed directory name '{}'".format(directory_name))

        self.meta = {}
        self.meta['artist'] = parts[0]
        self.meta['year'] = int(parts[1])
        self.meta['album'] = parts[2]

        # in compilation mode, artist will vary per track
        self.meta['album_artist'] = self.meta['artist']

        # clean '(Disc *)' from album name; don't want it in ID3 tag
        if '(Disc' in self.meta['album']:
            self.meta['album'] = self.meta['album'][0:self.meta['album'].find('(Disc')-1]

        # count mp3's for track total
        self.meta['total_num_tracks'] = len(fnmatch.filter(os.listdir(path), '*.mp3'))

        self.meta['image'] = None
        if os.path.exists(os.path.join(path, 'folder.jpg')):
            # extract existing 'FRONT_COVER' image
            # check new/existing has largest height
            # set largest as folder.jpg
            with open(os.path.join(path, 'folder.jpg'), 'rb') as f:
                self.meta['image'] = f.read()

        # load genre types / image types ?
        # TODO import pdb; pdb.set_trace()


ARGS_HELP = {
    '--force': 'Force removal of all existings tags.',
    '--compilation': 'Compilation album; sets TCMP frame, and expects each '
                     'track to contain artist name.',
    '--genre': 'Set the genre. If the argument is a standard ID3 genre '
               'name or number both will be set. Otherwise, any string '
               "can be used. Run 'eyeD3 --plugin=genres' for a list of "
               'standard ID3 genre names/ids.',
    '--eac': 'Set EAC as ripping tool in USER frame.',
    '--skip-tests': 'Skip eyeD3 test suite.',
    '--verbose': 'Show all available tag data',
}
