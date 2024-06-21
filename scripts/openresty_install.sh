#!/bin/bash
###
 # @Author: 星空
 # @Date: 2024-06-19 16:33:01
 # @LastEditTime: 2024-06-21 12:10:18
 # @LastEditors: 星空
 # @Description: 一键编译openresty
 # QQ: 1595601223
 # Mail: pluto@xkzs.cc
 # Copyright (c) 2024 by xkzs.cc All Rights Reserved.
###


# https://szr-data.oss-cn-beijing.aliyuncs.com/resource/openresty-1.25.3.1.tgz?OSSAccessKeyId=LTAI5tE9zbQaebV85rF67y3B&Expires=37713261896&Signature=yMnOjRvva6FhaxXxGDa059JrZn0%3D

set -e

zlib_version=1.3.1
pcre_version=8.45
openssl_version=3.2.1
openresty_version=1.25.3.1

openssl_prefix=/app/openresty/openssl-$openssl_version
zlib_prefix=/app/openresty/zlib
pcre_prefix=/app/openresty/pcre
openresty_prefix=/app/openresty


yum install -y ccache bzip2 pcre-devel openssl-devel gcc curl perl-IPC-Cmd make

if [ ! -d "openresty-source" ]; then
  mkdir openresty-source
else
  echo "Directory 'openresty-source' already exists, skipping creation."
fi

cd openresty-source

wget https://www.zlib.net/zlib-${zlib_version}.tar.xz
wget https://sourceforge.net/projects/pcre/files/pcre/${pcre_version}/pcre-${pcre_version}.tar.bz2
wget https://www.openssl.org/source/openssl-${openssl_version}.tar.gz
wget https://openresty.org/download/openresty-${openresty_version}.tar.gz


tar -xJf zlib-${zlib_version}.tar.xz
cd zlib-${zlib_version}
./configure --prefix=${zlib_prefix}
make -j`nproc` CFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
    SFLAGS='-O3 -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN -g3' \
    > /dev/stderr
make install
cd ..


tar -xjf pcre-${pcre_version}.tar.bz2
cd pcre-${pcre_version}
export CC="ccache gcc -fdiagnostics-color=always"
./configure \
  --prefix=${pcre_prefix} \
  --libdir=${pcre_prefix}/lib \
  --disable-cpp \
  --enable-jit \
  --enable-utf \
  --enable-unicode-properties
make -j`nproc` V=1 > /dev/stderr
make install
cd ..

tar zxf openssl-${openssl_version}.tar.gz
cd openssl-${openssl_version}/

./config \
    shared zlib -g3 \
    enable-camellia enable-seed enable-rfc3779 \
    enable-cms enable-md2 enable-rc5 \
    enable-weak-ssl-ciphers \
    enable-ssl3 enable-ssl3-method \
    --prefix=${openssl_prefix} \
    --libdir=lib \
    -I${zlib_prefix}/include \
    -L${zlib_prefix}/lib \
    -Wl,-rpath,${zlib_prefix}/lib:${openssl_prefix}/lib

make CC='ccache gcc -fdiagnostics-color=always' -j`nproc`
make install
cd ..


tar zxf openresty-${openresty_version}.tar.gz
cd openresty-${openresty_version}
./configure \
--prefix="${openresty_prefix}" \
--with-cc='ccache gcc -fdiagnostics-color=always' \
--with-cc-opt="-DNGX_LUA_ABORT_AT_PANIC -I${zlib_prefix}/include -I${pcre_prefix}/include -I${openssl_prefix}/include" \
--with-ld-opt="-L${zlib_prefix}/lib -L${pcre_prefix}/lib -L${openssl_prefix}/lib -Wl,-rpath,${zlib_prefix}/lib:${pcre_prefix}/lib:${openssl_prefix}/lib" \
--with-pcre-jit \
--without-http_rds_json_module \
--without-http_rds_csv_module \
--without-lua_rds_parser \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-http_v2_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_secure_link_module \
--with-http_random_index_module \
--with-http_gzip_static_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-threads \
--with-compat \
--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT' \
-j`nproc`

make -j`nproc`
make install
cd ..
