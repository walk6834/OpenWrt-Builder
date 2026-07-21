#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

function drop_package() {
	if [ "$1" != "golang" ]; then
		# feeds/base -> package
		find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
		find feeds/ -follow -name $1 -not -path "feeds/base/custom/*" | xargs -rt rm -rf
	fi
}
function clean_packages() {
	path=$1
	dir=$(ls -l ${path} | awk '/^d/ {print $NF}')
	for item in ${dir}; do
		drop_package ${item}
	done
}

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default IP
sed -i 's/192.168.1.1/192.168.1.5/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 第三方软件包
mkdir -p package/custom
git clone -b openwrt-25.12 --single-branch --depth 1 https://github.com/217heidai/OpenWrt-Packages.git package/custom
clean_packages package/custom
## golang
rm -rf feeds/packages/lang/golang
mv package/custom/golang feeds/packages/lang/
