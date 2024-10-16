# 个人 [Resources](https://github.com/Meteor-showers/Resources)

## 简介
这个项目是一个 个人使用的资源库，包含各类实用工具。

## 页面功能
- **[徽章生成器](https://g.xkzs.work/bdg.html)** `点击访问`
	- 选择logo添加标签内容和消息并选择颜色 即可生成如下 ![Meteorshowers](https://img.shields.io/badge/Meteorshowers-Demo-139840.svg?style=flat&labelColor=2c2a2d&logo=github)
- **[Github To jsDelivr](https://g.xkzs.work/g2j.html)** `点击访问`
	- : 将 GitHub 地址转为jsDelivr地址  CDN加速
- **[二维码生成](https://g.xkzs.work/qr.html)**`点击访问`
	- 生成和展示二维码。
- **[Singbox配置生成](https://g.xkzs.work/singbox.html)**`点击访问`
	- 填入订阅地址即可转换为Singbox配置

## 脚本功能
- **[ 抓线程日志](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/Grablog.sh)**`点击下载`
使用方法:
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/Grablog.sh -O Grablog.sh && bash Grablog.sh
# 按提示输入即可.
```
- **[IP黑名单](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/black_host.sh)**`点击下载`
使用方法:
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/black_host.sh -O /opt/black_host.sh;chmod +x /opt/black_host.sh
# 添加定时任务即可
*/10 * * * * /bin/bash /opt/black_host.sh
```
- **[ 初始化 linux](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/init_centos.sh)**`点击下载`
使用方法: `新机器执行`
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/init_centos.sh && bash init_centos.sh
# 按提示输入即可.
```
- **[Openresty 一键编译安装](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/openresty_install.sh)**`点击下载`
使用方法:
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/openresty_install.sh && bash openresty_install.sh
```
- **[一键添加/删除swap](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/swap.sh)**`点击下载`
使用方法:
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/swap.sh && bash swap.sh
# 按提示输入即可.
```
- **[一键卸载Docker](https://cdn.jsdelivr.net/gh/Meteor-showers/Resources@main/scripts/uninstall_docker.sh)**`点击下载`
使用方法:
```
wget https://raw.githubusercontent.com/Meteor-showers/Resources/refs/heads/main/scripts/uninstall_docker.sh && bash uninstall_docker.sh
```
