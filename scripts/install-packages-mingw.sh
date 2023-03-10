#!/bin/sh
pacman --noconfirm --needed -Sy \
    base-devel wget curl \
    make git \
    mingw-w64-x86_64-arm-none-eabi-gcc \
    mingw-w64-x86_64-arm-none-eabi-gdb \
    mingw-w64-x86_64-arm-none-eabi-newlib \
    mingw-w64-x86_64-arm-none-eabi-binutils \
    mingw-w64-x86_64-stlink \
    mingw-w64-x86_64-gdb-multiarch \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-SDL2 \
    python python-pip

pip3 install compiledb

printf "\n\n\ninstalling packages done!"
