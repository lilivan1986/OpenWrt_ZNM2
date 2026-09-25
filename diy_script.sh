```bash
#!/bin/bash

echo "自定义固件版本名字"

sed -i "/^\. \/etc\/openwrt_release/a\\
sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release\n\
echo \"DISTRIB_REVISION='v\$(date +'%Y.%m.%d')'\" >> /etc/openwrt_release\n\
sed -i '/DISTRIB_RELEASE/d' /etc/openwrt_release\n\
echo \"DISTRIB_RELEASE='v\$(date +'%Y.%m.%d')'\" >> /etc/openwrt_release\n\
sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release\n\
echo \"DISTRIB_DESCRIPTION='ImmortalWrt AutoBuild Firmware Compiled By @waynesg Build \$(TZ=UTC-8 date \"+%Y.%m.%d\") @ OpenWrt '\" >> /etc/openwrt_release
" package/emortal/default-settings/files/99-default-settings


echo "调整网络诊断地址到www.baidu.com"

sed -i "/exit 0/d" package/emortal/default-settings/files/99-default-settings

cat <<EOF >>package/emortal/default-settings/files/99-default-settings
uci set luci.diag.ping=www.baidu.com
uci set luci.diag.route=www.baidu.com
uci set luci.diag.dns=www.baidu.com
uci commit luci
exit 0
EOF


echo "修改最大连接数修改为65535"

sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf


echo "更换golang版本"

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang


echo "修改默认IP为192.168.100.1"

sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate


# ============================================================
# 删除 Nikki
# ============================================================

echo "不再安装 Nikki，跳过 Nikki 相关插件和 GeoIP 文件"


# ============================================================
# 添加 OpenClash
# ============================================================

echo "添加 OpenClash"

if ! grep -q "^src-git openclash " feeds.conf.default; then
    echo 'src-git openclash https://github.com/vernesong/OpenClash.git;master' >> feeds.conf.default
fi

./scripts/feeds update openclash
./scripts/feeds install -d y -p openclash luci-app-openclash


# ============================================================
# 添加 iStore 软件商店
# ============================================================

echo "添加 iStore 软件商店"

if ! grep -q "^src-git istore " feeds.conf.default; then
    echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
fi

./scripts/feeds update istore
./scripts/feeds install -d y -p istore luci-app-store


# ============================================================
# 再次更新全部 feeds
# ============================================================

echo "更新全部 feeds"

./scripts/feeds update -a
./scripts/feeds install -a


# ============================================================
# 修改版本为编译日期
# ============================================================

echo "修改固件版本号"

sed -i "s/^CONFIG_VERSION_NUMBER=.*/CONFIG_VERSION_NUMBER=\"$(date +%Y.%m.%d)\"/" .config
sed -i "s/^CONFIG_VERSION_CODE=.*/CONFIG_VERSION_CODE=\"R$(date +%Y%m%d)\"/" .config


echo "diy_script.sh 执行完成"
```
