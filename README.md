# Pi MusicBox Scripts
 A collection of scripts you can run on Pi Music Box to enhance your listening experience!

## Album Shuffler
If you're one of those people who likes to listen to full albums rather than individual songs, you'll **love** this! Simply copy the script + config file to your Pi MusicBox, define the storage path of your music in the config file and run the script to start shuffling your albums. Album listens will be stored in the working directory as `songs_listened_to.txt` in a format similar to the below;

```
31-01-2021_07_47-00: /music/USB/Music/Music/Alien Ant Farm/ANThology
31-01-2021_08_44-05: /music/USB/Music/Music/Fort Minor feat. Mr. Hahn/The Rising Tied
31-01-2021_08_49-06: /music/USB/Music/Music/CKY/Volume 1
31-01-2021_09_42-18: /music/USB/Music/Music/Billy Talent/Dead Silence
31-01-2021_10_37-43: /music/USB/Music/Music/Coldplay/A Rush of Blood to The Head
31-01-2021_11_10-25: /music/USB/Music/Music/Nirvana/Bleach
```

## Song Shuffler
If you like shuffling through songs, then you can use this script.  Simply copy the script + config file to your Pi MusicBox, define the storage path of your music in the config file and run the script to start shuffling your albums. Song listens be stored in the working directory as `songs_listened_to.txt` in a format similar to the below;

```
31-01-2021_11_37-24: /music/USB/Music/Music/Marilyn Manson/Eat Me, Drink Me/12 - Heart-Shaped Glasses (When the Heart Guides the Hand) [Inhuman Remix by Jade Puget].mp3
31-01-2021_11_37-44: /music/USB/Music/Music/Sutherland Brothers & Quiver/Simply Acoustic/09 - Arms of Mary.mp3
31-01-2021_11_37-50: /music/USB/Music/Music/Black Sabbath/Master Of Reality/06 - Lord Of The World.mp3
31-01-2021_11_37-57: /music/USB/Music/Music/Faith No More/The Real Thing/03 - Falling To Pieces_1.mp3
31-01-2021_11_38-01: /music/USB/Music/Music/Linkin Park feat. Pusha T & Stormzy/One More Light/02 - Good Goodbye.mp3
```

## Scheduled Shutdown
Pi MusicBox doesn't have any kind of sleep timer so I built this script to help. Simply run `shutdown.sh`, enter the number of minutes before shutdown and the box will shutdown after that number of minutes has elapsed.

## How to run the scripts
Once you have transferred the scripts to your Pi MusicBox, you have to SSH into the box and run;

```
perl random_song_player.pl

or

perl random_music_player.pl

or

bash shutdown.sh
```

This will start playing music until the script is terminated (with Control + C) or if the box is rebooted.

You can also add the script to rc.local to have the randomiser scripts run on system boot. Add one of the lines to `/etc/rc.local/` to enable this.

The scripts will terminate if you run exit your SSH session. In order to run them whilst logging out of your SSH session, use `screen`;
- Type `screen` then enter
- Run one of the scripts.
- Hit Control + A
- Hit Control + D

This will run the script inside a screen and allow you to exit your SSH session but still keep your scripts running.