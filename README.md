# Digital signage solution based on flutter-pi

## Features and limitatins

- Raspberry Pi digital signage without X11 or Wayland (based on [flutter-pi](https://github.com/ardera/flutter-pi))
- Setup script template to setup your Pi (based on Raspberry Pi OS Lite, based on Debian 12, `2024-07-04-raspios-bookworm-armhf-lite.img.xz`)
- Web-based preview (based on Flutter web and Flask), enable user to preview the result without visiting the signage installation site
- Tested on Raspberry Pi 2

## Architecture

- Raspberry Pi (can be installed benind NAT)
    - Digital signage applcation based on flutter-pi
    - A script to synchronise files (JPEG) from WebDAV server (using rclone)
    - Watchdog to reboot system
    - Wireghard for remote access (to debug/troubleshoot a pi in operation)
- A server (or three) with a public IP
    - WebDAV server (e.g. NextCloud)
        - to store slides (JPEG files)
    - Web server for preview (e.g. Apache)
        - Host static content (Flutter web)
        - Host Flask app to synchronise slides (JPEG) from WebDAV server, and return a list of slides
    - WireGuard server
        - For remote troubleshooting

## How to build and setup

1. On Debian 12 (as a build machine, does not need to be the server), run:
    ```shell
    cd flutter-code
    ./build  # will generate flutter_assets.tar.lz4 and signage-preview.tar.lz4
             # flutter_assets.tar.lz4 contains digital signage application for Raspberry Pi
             # signage-preview.tar.lz4 contains HTML and JavaScript for web-based signage preview
    ```
2. Setup WebDAV server (e.g. NextCloud) and setup a folder for the slides, generate login credeitnals, and update `rclone.conf`generate rclone config
3. Customise the config in "pi" directory, and run each of the setup sccript on Raspberry Pi
4. Customise the config in "server" directory, and run each of the setup sccript on your web server (Apache) 

