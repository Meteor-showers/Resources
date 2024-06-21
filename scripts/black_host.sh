#!/bin/bash
###
# @Author: 星空
# @Date: 2024-06-19 16:33:01
# @LastEditTime: 2024-06-21 12:08:16
# @LastEditors: 星空
# @Description: Denyhosts SHELL SCRIPT
# QQ: 1595601223
# Mail: pluto@xkzs.cc
# Copyright (c) 2024 by xkzs.cc All Rights Reserved.
###

# 分析登录日志文件，筛选失败登录并统计次数存入文件备用
cat /var/log/secure | awk '/Failed/{print $(NF-3)}' | sort | uniq -c | awk '{print $2"=" $1;}' >/root/Denyhosts.txt
# 定义允许失败登录的次数
DEFINE="10"
# 读取文件，并把条件范围内的IP写到hosts.deny中，实现黑名单效果
for i in $(cat /root/Denyhosts.txt); do
  IP=$(echo $i | awk -F= '{print $1}')
  NUM=$(echo $i | awk -F= '{print $2}')
  if [ $NUM -gt $DEFINE ]; then
    ipExists=$(grep $IP /etc/hosts.deny | grep -v grep | wc -l)
    if [ $ipExists -lt 1 ]; then
      echo "sshd:$IP" >>/etc/hosts.deny
    fi
  fi
done
