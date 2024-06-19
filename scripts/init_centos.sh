#!/bin/bash
#
# @Author: 星空
# @Date: 2024-01-05 17:32:29
# @Last Modified by: 星空
# @Last Modified time: 2024-01-05 17:32:29
#
#################################################
#  --Info
#         Initialization CentOS 7.x script
#  --Nice day!

# Check if user is root
#

if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to initialization OS."
    exit 1
fi

echo "+------------------------------------------------------------------------+"
echo "|       To initialization the system for security and performance        |"
echo "+------------------------------------------------------------------------+"

declare -g full_name
declare -g new_username
declare -g userpassword
declare -g sshprot

# modify hostname
modify_hostname()
{
    read -p "Enter a name for the machine: " machine_name
    ip_address=$(hostname -I | awk '{print $1}')
    ip_last_two=$(echo "$ip_address" | awk -F. '{print $(NF-1)$NF}')
    full_name="${machine_name}-$ip_last_two"
    hostnamectl --static set-hostname "$full_name"
    echo "Hostname modifyed $full_name."
}

# add  user
user_add()
{
    # add user for use
    read -p "Enter username for the new user: " new_username
    if id "$new_username" >/dev/null 2>&1; then
        echo "User $new_username already exists."
    else
        read -s -p "Enter password for $new_username: " userpassword
        echo
        useradd -s /bin/bash -d "/home/$new_username" -m "$new_username" && echo "$userpassword" | passwd --stdin "$new_username" && echo "$new_username ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$new_username"
        echo "User $new_username successfully added"
    fi
}

# update system & install pakeage
system_update(){
    echo "*** Starting update system && install tools pakeage... ***"
    yum install epel-release -y && yum -y update
    yum clean all && yum makecache
    yum install -y bash-completion vim lrzsz wget expect net-tools nc nmap rsync lsof tcpdump traceroute man tree dos2unix htop iftop iotop unzip sysstat telnet sl psmisc nethogs glances bc ntpdate vim-enhanced openldap-devel nano dig git screen
    [ $? -eq 0 ] && echo "System upgrade && install pakeages complete."
}

# Set timezone synchronization
timezone_config()
{
    echo "Setting timezone..."
    /usr/bin/timedatectl | grep "Asia/Shanghai"
    if [ $? -eq 0 ];then
        echo "System timezone is Asia/Shanghai."
        else
        timedatectl set-local-rtc 0 && timedatectl set-timezone Asia/Shanghai
    fi
    # config chrony
    yum -y install chrony && systemctl start chronyd.service && systemctl enable chronyd.service
    sed -i 's/server 0.centos.pool.ntp.org iburst/server ntp.aliyun.com iburst/g' /etc/chrony.conf
    sed -i 's/server 1.centos.pool.ntp.org iburst/server time1.cloud.tencent.com  iburst/g' /etc/chrony.conf
    sed -i 's/server 2.centos.pool.ntp.org iburst/server ntp.tuna.tsinghua.edu.cn iburst/g' /etc/chrony.conf
    sed -i 's/server 3.centos.pool.ntp.org iburst/server cn.ntp.org.cn iburst/g' /etc/chrony.conf
    systemctl restart chronyd.service
    [ $? -eq 0 ] && echo "Setting timezone && Sync network time complete."
}

# disable selinux
selinux_config()
{
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
    echo "Dsiable selinux complete."
}

# ulimit comfig
ulimit_config()
{
echo "Starting config ulimit..."
cat >> /etc/security/limits.conf <<EOF
* soft nproc 8192
* hard nproc 8192
* soft nofile 8192
* hard nofile 8192
EOF

[ $? -eq 0 ] && echo "Ulimit config complete!"

}

# sshd config
sshd_config(){
    echo "Starting config sshd..."
    #sed -i '/^#Port/s/#Port 22/Port 2188/g' /etc/ssh/sshd_config
    #sed -i "$ a\ListenAddress 0.0.0.0:2188\nListenAddress 0.0.0.0:22 " /etc/ssh/sshd_config
    #sed -i '/^#UseDNS/s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    #sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    #sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    sed -i '$a PasswordAuthentication yes' /etc/ssh/sshd_config
    sed -i '$a UseDNS no' /etc/ssh/sshd_config
    sed -i '$a Port 2188' /etc/ssh/sshd_config
    sed -i '$a PermitRootLogin no' /etc/ssh/sshd_config
    sed -i '$a PubkeyAuthentication yes' /etc/ssh/sshd_config
    sed -i '$a Protocol 2,1' /etc/ssh/sshd_config
    systemctl restart sshd
    [ $? -eq 0 ] && echo "SSH config complete."
    sshprot=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')
}

# firewalld config
disable_firewalld(){
    echo "Starting disable firewalld..."
    rpm -qa | grep firewalld >> /dec/null
    if [ $? -eq 0 ];then
        systemctl stop firewalld  && systemctl disable firewalld
        [ $? -eq 0 ] && echo "Dsiable firewalld complete."
    else
        echo "Firewalld not install."
    fi
}

# vim config
vim_config() {
    echo "Starting vim config..."
    /usr/bin/egrep pastetoggle /etc/vimrc >> /dev/null
    if [ $? -eq 0 ];then
        echo "vim already config"
    else
        sed -i '$ a\set bg=dark\nset pastetoggle=<F9>' /etc/vimrc
    fi
    echo "vim config complete."
}

# sysctl config

config_sysctl() {
    echo "Staring config sysctl..."
    /usr/bin/cp -f /etc/sysctl.conf /etc/sysctl.conf.bak
    cat > /etc/sysctl.conf << EOF
# Minimizing the amount of swapping
vm.swappiness = 20
vm.dirty_ratio = 80
vm.dirty_background_ratio = 5

# Increases the size of file handles and inode cache & restricts core dumps
fs.file-max = 2097152
fs.suid_dumpable = 0

# Change the amount of incoming connections and incoming connections backlog
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 262144

# Increase the maximum amount of memory buffers
net.core.optmem_max = 25165824

# Increase the default and maximum send/receive buffers
net.core.rmem_default = 31457280
net.core.rmem_max = 67108864
net.core.wmem_default = 31457280
net.core.wmem_max = 67108864

# Enable TCP SYN cookie protection
net.ipv4.tcp_syncookies = 1

# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter = 1

# Enable ignoring to ICMP requests and broadcasts request
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable logging of spoofed packets, source routed packets and redirect packets
net.ipv4.conf.all.log_martians = 1

# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
EOF

    /usr/sbin/sysctl -p
    [ $? -eq 0 ] && echo "Sysctl config complete."
}

# ipv6 config
disable_ipv6() {
    echo "Starting disable ipv6..."
    sed -i '$ a\net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf
    sed -i '$ a\AddressFamily inet' /etc/ssh/sshd_config
    systemctl restart sshd
    /usr/sbin/sysctl -p
    echo "IPv6 was disabled."
}

# password config
password_config() {
    # /etc/login.defs
    sed -i 's/PASS_MIN_LEN    5/PASS_MIN_LEN    8/g' /etc/login.defs
    authconfig --passminlen=8 --update
    authconfig --enablereqlower --update
    [ $? -eq 0 ] && echo "Config password rule complete."
}

# disable no use service
disable_serivces() {
    systemctl stop postfix && systemctl enable postfix
    [ $? -eq 0 ] && echo "Disable postfix service complete."
}

#main function
main(){
    modify_hostname
    sleep 2
    user_add
    sleep 2
    system_update
    sleep 2
    timezone_config
    sleep 2
    selinux_config
    sleep 2
    ulimit_config
    sleep 2
    sshd_config
    sleep 2
    disable_firewalld
    sleep 2
    vim_config
    sleep 2
    config_sysctl
    sleep 2
    disable_ipv6
    sleep 2
    password_config
    sleep 2
    disable_serivces
    sleep 2
}

# execute main functions
main
echo "+------------------------------------------------------------------------+"
echo "|            To initialization system all completed !!!                  |"
echo "+------------------------------------------------------------------------+"
echo "|                          Nice day to you                               |"
echo "+------------------------------------------------------------------------+"
echo "|                Modify your terminal link configuration                 |"
echo "+------------------------------------------------------------------------+"
echo "                        HostName    "$full_name"                          "
echo "+------------------------------------------------------------------------+"
echo "     username:"$new_username" | password:"$userpassword" port:"$sshprot"  "
echo "+------------------------------------------------------------------------+"

new_username=""
userpassword=""
full_name=""
sshprot=""

# Clear command history
history -c
