# Raspberry Pi TV Player

This project is designed to automatically play mp4 files from any USB drive inserted into a raspberry pi 4B. It uses mpv to display the video and a default splash screen. This project is implemented via a udev rule to automatically mount any usb drives inserted into the Pi and a systemd service to continually poll the mount directory for any video files.

Any media files on the USB drive should be placed into the root directory. See the `assets/test-footage` directory for an example video that is able to be played using the Pi. Note that depending on the .

When not playing a video, the Pi will display a splash screen, which is currently stored in the `assets` directory of this project. Edit it to change it, and then reinstall the program.

## Installation

To install the project on a raspberry Pi, run the following command in the project root:

```shell
sudo make install
```

To uninstall, run the following command in the project root:

```shell
sudo make uninstall
```

Note that because this creates a systemd service that is constantly using the main display, you will not be able to easily type this if you are controlling the pi via an HDMI display. The uninstall command can be typed blind after login, but should be run from an ssh shell or similar.

## Dependencies

This project depends on the following dependencies: `mpv socat`

install them with `sudo apt install mpv socat`

## Attributions

Sample video footage: [Big Buck Bunny](https://peach.blender.org/)  
© 2008 Blender Foundation | [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)  
Used as test footage during development and demonstration.

The udev rule is modified from the [example found here](https://wiki.archlinux.org/title/Udev#Mounting_drives_in_rules) on the arch linux wiki.
