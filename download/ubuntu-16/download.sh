#!/bin/bash

if [ "$1"  == "bash" ];then
    exec /bin/bash
else
    PKG_PATH=/opt/rainbond/install/install/pkgs
    apt update
    echo "download ubuntu offline package"
    dpkg=(nfs-kernel-server nfs-common dnsutils python-pip python-apt apt-transport-https uuid-runtime iproute2 systemd)
    common_pkg=(tar ntpdate wget curl tree lsof htop nload net-tools telnet rsync git dstat salt-master salt-minion salt-ssh iotop lvm2 ntpdate pwgen)
    k8s_pkg=(kubelet=1.10.11-00 kubectl=1.10.11-00 kubeadm=1.10.11-00)
    docker_pkg=(docker-ce=17.05.0~ce)
    for pkg in ${dpkg[@]} ${common_pkg[@]} ${k8s_pkg[@]} ${docker_pkg[@]}
    do
        apt install ${pkg} -d -y  >/dev/null 2>&1
        echo "download ubuntu $pkg ok"
    done
    cp -a /var/cache/apt/archives/*.deb /tmp/
    apt-get install reprepro -y
    mkdir -p /opt/rainbond/install/install/pkgs/ubuntu/16/conf/
    touch /opt/rainbond/install/install/pkgs/ubuntu/16/conf/{distributions,options,override.local}
    cat > /opt/rainbond/install/install/pkgs/ubuntu/16/conf/distributions <<EOF
Origin: rainbond
Label: rainbond
Codename: local
Architectures: amd64
Components: main pre
Description: rainbond ubuntu package local repo 
EOF
    cat > /opt/rainbond/install/install/pkgs/ubuntu/16/conf/options <<EOF
verbose
basedir /opt/rainbond/install/install/pkgs/ubuntu/16/
EOF
    for deb in /tmp/*
    do  
        echo $deb | grep ".deb" && (
            reprepro -Vb /opt/rainbond/install/install/pkgs/ubuntu/16  -C main -P optional -S net  includedeb local $deb 
        )
    done
fi