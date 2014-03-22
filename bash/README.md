mp3-scripts
===========

ID3 tagging and M3U playlist utility scripts.


History
-------

This started out as a couple of bash scripts to help with automated tagging of my music collection. It seemed to me easiest to just edit directory and filenames as opposed to using one of the myriad tagging apps out there. Now if there was only a way to convert that into MP3 tags..

Over time the feature set grew to what's here now. Originally based around the "id3v2" application, it now uses the python eyeD3 application for its superior character set support.

The origin of the directory/filename rules applied by the id3-autotag.sh script is the Ubernet music sharing group which used DC++ all those years ago.


Dependencies
------------

`sudo aptitude install eyeD3`

`sudo aptitude -R install imagemagick, iconv`


ENV Variable
------------

Many of the scripts in this package reference your music collection in some way. To this end, it's convenient to set the environment variable to the base directory of your MP3 collection. Alternatively, you can pass the **-d** parameter to a script which can use it.

`export MUSIC_DIR=/home/mafrosis/mp3`


### id3-autotag.sh
By naming directories and files according to a simple set of rules, this script then automatically tag your MP3s.

The naming convention for your MP3 directories and files as follows:

> Tool - 2001 - Lateralus/03 - The Patient.mp3

> The Neil Cowley Trio - 2010 - Radio Silence/09 - Portal.mp3

> Danger Doom - 2005 - The Mouse And The Mask/07 - A.T.H.F..mp3

`<Artist> - <Year> - <Album>/<Num> - <Title>.mp3`

The script will then create the correct tag and also do the following extras:

 * Broken tags will be removed and recreated - with valid character encodings.
 * If a file exists called **folder.jpg**, it will be applied as album art.
 * Genre will be validated; it is removed if it's bad.
 * The compilation flag will create iTunes' ICMP frame.
 * The eac flag will write a text frame indicating a track was ripped with EAC.

`id3-autotag.sh [-c compilation] [-f force] [-e eac] [filename]`


### id3-autoname.sh
Recursively rename MP3 files applying the above rules. This also handles UTF8 characters in the filename with iconv.

`id3-autoname.sh [-c compilation] [filename]`


### id3-setaa.sh
Recursively set the Album Artist tag on some MP3s. This will copy the value from the Artist field if Album Artist is not supplied.

`id3-setaa.sh path [albumartist]`


### id3-seteac.sh
Recursively set a text frame indicating a track was ripped with EAC.

`id3-seteac.sh path`


### id3-setgenre.sh
Recursively set a genre on some MP3s. This also validates the genre against the valid list.

`id3-setgenre.sh genre path`


### m3u-create.sh
Create an M3U of the current directory.

`m3u-create [-o overwrite] path`


### m3u-fix.sh
Fix M3U playlists which have now have missing MP3s. This script will iteratively search your music directory and assist offer options for each missing track in a playlist.

`m3u-fix.sh [-d mp3-directory] [-p m3u-playlist]`


### m3u-gather.sh
Pull all tracks in an M3U playlist out into another directory. This is useful for sharing playlists or a burning CD.

`m3u-gather.sh [-p m3u-playlist] [-o output-path]`

