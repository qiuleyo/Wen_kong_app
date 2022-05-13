
echo 
echo 找到的温控文件
echo
echo
find /system /vendor /product /system_ext -type f -iname "*thermal*" -exec ls -s -h {} \; 2>/dev/null | sed '/hardware/d'
echo
echo ------------------使用说明--------------------
echo 请查看文件名前的大小是否为"0"，如果不是0则代表屏蔽失败，反之则屏蔽成功。
echo
echo
echo 647299031反馈群
echo