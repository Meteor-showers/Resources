#!/bin/bash
###
 # @Author: 星空
 # @Date: 2024-06-19 16:33:01
 # @LastEditTime: 2024-06-21 12:10:33
 # @LastEditors: 星空
 # @Description: PVE 源
 # QQ: 1595601223
 # Mail: pluto@xkzs.cc
 # Copyright (c) 2024 by xkzs.cc All Rights Reserved.
###

dir="/etc/apt/sources.list.d/"
file="/etc/apt/sources.list"

if [ -d "$dir" ]; then
  echo "Deleting directory $dir..."
  rm -rf "$dir"
  echo "Directory deleted."
else
  echo "Directory $dir does not exist. Skipping deletion."
fi

echo "Replacing content of $file..."

echo "deb https://mirrors.ustc.edu.cn/debian/ bookworm main contrib non-free non-free-firmware" > "$file"
echo "deb https://mirrors.ustc.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware" >> "$file"
echo "deb https://mirrors.ustc.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware" >> "$file"
echo "deb https://mirrors.ustc.edu.cn/debian-security bookworm-security main" >> "$file"
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian bookworm pve-no-subscription" >> "$file"

echo "Content replaced."
