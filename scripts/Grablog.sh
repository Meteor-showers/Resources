#!/bin/bash
# @Author: 星空
# @Date: 2023-12-29 18:26:48
# @Last Modified by: 星空
# @Last Modified time: 2023-12-29 18:28:56

# 提示用户输入日志文件路径
read -p "Enter logfile: " logfile

# 提示用户输入需要过滤的 UUID，用空格分隔
read -p "Enter UUIDs (separated by space): " -a uuids

# 提示用户选择输出方式：直接输出或保存到文件
read -p "Output to a file? (yes/no): " outputToFile
if [[ $outputToFile == "yes" ]]; then
    read -p "Enter output filename (default is elog.txt): " outputFilename
    if [[ -z $outputFilename ]]; then
        outputFilename="elog.txt"
    fi
fi

# 检测日志文件是否为压缩格式
isCompressed=false
if [[ ${logfile} == *".gz" ]]; then
    isCompressed=true
fi

# 处理每个 UUID
for uuid in "${uuids[@]}"; do
    if $isCompressed; then
        firstLine=$(zcat "${logfile}" | grep -n "${uuid}" | head -n 1 | awk -F : '{print $1}')
        lastLine=$(zcat "${logfile}" | grep -n "${uuid}" | tail -n 1 | awk -F : '{print $1}')
        if [[ $outputToFile == "yes" ]]; then
            zcat "${logfile}" | sed -n "${firstLine},${lastLine}p" | grep -E "${uuid}|^[[:space:]]*java|^[[:space:]]*com|^[[:space:]]*Caused by|^[[:space:]]*org|^[[:space:]]*at" >> $outputFilename
            echo "" >> $outputFilename
        else
            zcat "${logfile}" | sed -n "${firstLine},${lastLine}p" | grep -E "${uuid}|^[[:space:]]*java|^[[:space:]]*com|^[[:space:]]*Caused by|^[[:space:]]*org|^[[:space:]]*at"
            echo ""
        fi
    else
        firstLine=$(grep -n "${uuid}" < "${logfile}" | head -n 1 | awk -F : '{print $1}')
        lastLine=$(grep -n "${uuid}" < "${logfile}" | tail -n 1 | awk -F : '{print $1}')
        if [[ $outputToFile == "yes" ]]; then
            sed -n "${firstLine},${lastLine}p" < "${logfile}" | grep -E "${uuid}|^[[:space:]]*java|^[[:space:]]*com|^[[:space:]]*Caused by|^[[:space:]]*org|^[[:space:]]*at" >> $outputFilename
            echo "" >> $outputFilename
        else
            sed -n "${firstLine},${lastLine}p" < "${logfile}" | grep -E "${uuid}|^[[:space:]]*java|^[[:space:]]*com|^[[:space:]]*Caused by|^[[:space:]]*org|^[[:space:]]*at"
            echo ""
        fi
    fi
done
