#!/bin/bash
###
 # @Author: 星空
 # @Date: 2024-06-21 10:48:16
 # @LastEditTime: 2024-06-21 12:12:23
 # @LastEditors: 星空
 # @Description: 一键卸载 Docker 脚本
 # QQ: 1595601223
 # Mail: pluto@xkzs.cc
 # Copyright (c) 2024 by xkzs.cc All Rights Reserved.
###

# 检查是否具有root权限
if [ "$(id -u)" != "0" ]; then
    echo "此脚本必须以root用户或使用sudo权限运行" 1>&2
    exit 1
fi

# 识别操作系统
OS=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/redhat-release ]; then
    OS="rhel"
else
    echo "不支持的操作系统"
    exit 1
fi

# 列出已安装的Docker相关组件
echo "列出已安装的Docker相关组件..."
case "$OS" in
ubuntu | debian)
    DOCKER_PACKAGES=$(dpkg -l | grep -E 'docker|containerd' | awk '{print $2}')
    ;;
rhel | centos)
    DOCKER_PACKAGES=$(rpm -qa | grep -E 'docker|containerd')
    ;;
fedora)
    DOCKER_PACKAGES=$(dnf list installed | grep -E 'docker|containerd' | awk '{print $1}')
    ;;
opensuse | sles)
    DOCKER_PACKAGES=$(zypper se --installed-only | grep -E 'docker|containerd' | awk '{print $2}')
    ;;
*)
    echo "不支持的操作系统"
    exit 1
    ;;
esac

if [ -n "$DOCKER_PACKAGES" ]; then
    echo "检测到的Docker相关组件：$DOCKER_PACKAGES"
else
    echo "未检测到Docker相关组件"
fi

# 确认卸载
read -p "确定要卸载这些组件并删除相关数据吗？[y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "卸载已取消"
    exit 0
fi

# 删除所有 Docker 网络
echo "删除所有 Docker 网络..."
docker network prune -f

# 停止Docker服务
echo "停止Docker服务..."
systemctl stop docker
systemctl disable docker

# 杀死所有Docker相关进程
echo "杀死所有Docker相关进程..."
pkill -f docker

# 卸载Docker相关组件
echo "卸载Docker相关组件..."
if [ -n "$DOCKER_PACKAGES" ]; then
    case "$OS" in
    ubuntu | debian)
        echo "正在使用apt-get卸载组件..."
        apt-get purge -y $DOCKER_PACKAGES
        apt-get autoremove -y --purge
        ;;
    rhel | centos)
        echo "正在使用yum卸载组件..."
        yum remove -y $DOCKER_PACKAGES
        yum autoremove -y
        ;;
    fedora)
        echo "正在使用dnf卸载组件..."
        dnf remove -y $DOCKER_PACKAGES
        dnf autoremove -y
        ;;
    opensuse | sles)
        echo "正在使用zypper卸载组件..."
        zypper remove -y $DOCKER_PACKAGES
        ;;
    esac
fi

# 删除Docker相关的目录和数据
echo "删除Docker相关的目录和数据..."
directories=(
    /var/lib/docker
    /var/lib/containerd
    /etc/docker
    /var/run/docker.sock
    /var/log/docker
    /var/log/containerd
    /run/docker
    /etc/systemd/system/docker.service.d
    /etc/systemd/system/docker.socket.d
    /var/lib/kubelet/plugins_registry/docker
)
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "删除目录：$dir"
        rm -rf "$dir"
    fi
done

# 删除用户目录中的Docker配置和缓存
echo "删除用户目录中的Docker配置和缓存..."
user_dirs=$(find /root /home -type d -name '.docker')
for user_dir in $user_dirs; do
    if [ -d "$user_dir" ]; then
        echo "删除目录：$user_dir"
        rm -rf "$user_dir"
    fi
done

# 删除可能的日志和缓存文件
echo "删除日志和缓存文件..."
logs=(
    /var/log/upstart/docker.log
    /var/cache/docker
)
for log in "${logs[@]}"; do
    if [ -f "$log" ]; then
        echo "删除文件：$log"
        rm -f "$log"
    fi
done

# 清理与Docker相关的iptables规则
echo "清理与Docker相关的iptables规则..."
iptables-save | grep -v 'DOCKER' | iptables-restore

# 获取所有符合条件的 Docker 网络接口，并按倒序排序
docker_interfaces=$(ip link show | grep -E 'docker0|br-[[:alnum:]]{12}' | awk '{print $2}' | awk -F':' '{print $1}' | sed 's/@.*//' | sort -r)

# 遍历并删除每个网络接口
for iface in $docker_interfaces; do
    echo "尝试删除网络接口：$iface"
    ip link delete "$iface" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "成功删除网络接口：$iface"
    else
        echo "删除网络接口 $iface 失败，可能是因为该接口正在被使用或者没有足够的权限。"
    fi
done

# 删除Docker组（如果存在）
if getent group docker >/dev/null 2>&1; then
    echo "删除Docker组..."
    groupdel docker
fi

echo "Docker已成功卸载"

# 提示用户重启系统
echo "建议重启系统以确保所有更改生效。请运行以下命令进行重启："
echo "sudo reboot"

# 提示重新安装 Docker 方式
echo "如果要重新安装 Docker 的话 请在root权限下运行以下命令进行安装: "
echo "curl -fsSL get.docker.com | sh"
