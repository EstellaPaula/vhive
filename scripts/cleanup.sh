#!/bin/bash

# MIT License
#
# Copyright (c) 2020 Shyam Jesalpura and EASE lab
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo kubeadm reset --cri-socket /etc/firecracker-containerd/fccd-cri.sock -f
sudo pkill -INT vhive
sudo pkill -9 firecracker-containerd
sudo pkill -9 firecracker
sudo pkill -9 containerd

echo Removing devmapper devices
for de in `sudo dmsetup ls| cut -f1|grep thinpool`; do sudo dmsetup remove $de && echo Removed $de; done
sudo dmsetup remove fc-dev-thinpool

sudo rm /etc/firecracker-containerd/fccd-cri.sock
rm ${HOME}/.kube/config
sudo rm -rf ${HOME}/tmp

echo Cleaning /var/lib/firecracker-containerd/*
for d in containerd shim-base snapshotter; do sudo rm -rf /var/lib/firecracker-containerd/$d; done

echo Cleaning /run/firecracker-containerd/*
sudo rm -rf /run/firecracker-containerd/containerd.sock.ttrpc \
    /run/firecracker-containerd/io.containerd.runtime.v1.linux \
    /run/firecracker-containerd/io.containerd.runtime.v2.task

echo Creating a fresh devmapper
$PWD/create_devmapper.sh