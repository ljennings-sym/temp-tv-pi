# Raspberry Pi TV Player

This project is designed to automatically play mp4 files from any USB drive inserted into a raspberry pi 4B. It uses VLC to make sure that video decoding works correctly. 

Any media files on the USB drive should be placed into the root directory, and be encoded in the h264/AAC format. See the `test-footage` directory for an example video that is able to be played using the built in video decoders on the Pi. If a video is not in this format, it will likely be very laggy when played.

When not playing a video, the pi will display a splash screen, which is currently stored in the `splash` directory of this project. Edit it to change it, and then reinstall the program so that it shows up after the next reboot.

To escape out of the player, plug in a keyboard and hit `q` while the splash image is shown or `esc` while a video is showing. 

## Installation

To install the project on a raspberry pi, run the following command in the project root:
```shell
make install
```

## Dependencies

This project depends on the following dependencies:

```
vlc imv
```

install them with `sudo apt install vlc imv`

## Media Attribution

Sample video footage: [Big Buck Bunny](https://peach.blender.org/)  
© 2008 Blender Foundation | [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)  
Used as example test footage for demonstration purposes.

