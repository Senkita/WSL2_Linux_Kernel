###
 # @Description: 编译WSL2 Linux Kernel
 # @Author: Senkita
 # @Date: 2022-02-28 17:43:30
 # @LastEditors: Senkita
 # @LastEditTime: 2022-03-04 12:10:24
###
# !/bin/bash

if [ -n "$__MODULE_SH__" ]; then
    return
fi
__MODULE_SH__='build.sh'

# 安装依赖
sudo apt update
sudo apt install -y w3m git tar wget gcc build-essential bison flex libelf-dev libssl-dev bc make python3 kmod

# 下载最新版Linux内核
linux_kernel_url="https://www.kernel.org/"
linux_kernel_href=$(w3m -dump_source $linux_kernel_url|grep https://git.kernel.org/torvalds/t/)
linux_kernel_url=$(echo $linux_kernel_href|awk -F'"' '{print $2}')

wget -nv $linux_kernel_url -O linux.tar.gz

mkdir linux
tar zxf linux.tar.gz -C linux/ --strip-components=1

# 拉取WSL2内核
mkdir WSL2-Linux-Kernel
git clone https://github.com/microsoft/WSL2-Linux-Kernel.git --depth 1 --single-branch ./WSL2-Linux-Kernel/

# 打补丁
diff -uNra linux/ WSL2-Linux-Kernel/ > patchfile
cd linux
patch -p1 --forward < ../patchfile

# 下载配置
wget -nv https://gist.githubusercontent.com/Senkita/00ff33245349b1ba6247a37d0a0a49a1/raw/6243e13c8320c1985aa6480c87a0f4a4191910f1/config-wsl -O .config

# 构建
sudo chmod -R +x ../linux/
sudo make KCONFIG_CONFIG=.config -j$(nproc)
sudo make modules KCONFIG_CONFIG=.config -j$(nproc)

# 清理
sudo rm -rf ../WSL2-Linux-Kernel/
sudo rm ../linux.tar.gz ../patchfile
