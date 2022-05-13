SKIPUNZIP=0
source $MODPATH/system/vendor/etc/.tp/policy
echo " "
echo "*******************"
echo "- 手机信息"
echo "- SDK: $(getprop ro.build.version.sdk)"
echo "- 设备: $(getprop ro.fota.oem)"
echo "- 设备代号: $(getprop ro.product.device)"
echo "- 安卓版本: Android $(getprop ro.build.version.release)"
echo "*******************"
echo ""
echo "- 模块ID: $MODID"
echo "- 作者: 酷安@Qiu_le"
echo "- 介绍: 本模块是通过采用Magisk方式移除温控,联网会检查更新"
echo "****************************"
echo "- 安装此模块可能会导致某些机型跳电"
echo "- 如需恢复温控卸载模块即可"
echo "****************************"
echo " "
cp -af $MODPATH/system/freeze.sh /data/media/0/Android/
cp -af $MODPATH/system/Unfreezed.sh /data/media/0/Android/
cp -af $MODPATH/system/检查温控.sh /data/media/0/Android/
echo "- 冻结云控和检查温控脚本已保存在Android目录请自行选择执行"
echo "- 冻结云控和检查温控脚本已保存在Android目录请自行选择执行"
echo "- 冻结云控和检查温控脚本已保存在Android目录请自行选择执行"
echo "- 交流群:647299031"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  ui_print "install..."