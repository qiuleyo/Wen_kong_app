#!/data/user/0/com.fuckwenkong/files/busybox/toolkit/sh
echo '<?xml version="1.0" encoding="utf-8"?>'
RELOAD="true"
MODDIR="/data/adb/modules"
[[ -d "${MODDIR}" ]] || MODDIR="/data/adb/lite_modules"
MODPATH="${MODDIR}/Wen_kong"
GITEE="https://gitee.com/qiuleyo/wen_kong_app/tree/master"

LOGURL="${GITEE}/update.log"
MODURL="https://gitee.com/qiuleyo/wen_kong_app/raw/master/Wen_kong-v4.3.zip"
MODMD5="83f0b82a652fcd565fdc21e32696f07f"
MODVERSION="v4.3"
function download(){
	if [[ ${1} == fix ]]; then
		cat <<-EOF
			<group>
				<action reload="true">
					<title>${2##*/}校验md5不正确，点击修复</title>
					<param
						name="ORIGIN"
						label="选择修复源">
						<option value="${GITEE}">GITEE</option>
					
					</param>
					<set>
						echo '-稍等,联网下载最新文件中'
						curl -o ${TEMP_DIR}/fix -sL \${ORIGIN}/${2}
						echo '-下载完成,校验md5'
						md5sum ${TEMP_DIR}/fix | grep ${3} >/dev/null
						if [[ \$? -eq 0 ]]; then
							echo '-校验完成,开始修复'
							cp -f ${TEMP_DIR}/fix ${MODPATH}/${2}
							if [[ \$? -eq 0 ]]; then
								rm -f ${TEMP_DIR}/fix
								chmod 777 ${MODPATH}/${2}
								echo '-修复完成,即将重新启动'
								nohup ${SERVICE} >/dev/null 2>&#38;1
								if [[ \$? -eq 0 ]]; then
									echo '-启动成功'
								else
									echo '-启动失败'
								fi
							else
								echo '-修复失败,请重试'
							fi
						else
							rm -f ${TEMP_DIR}/fix
							echo '-md5校验失败，请重试'
						fi
					</set>
				</action>
			</group>
		EOF
	else
		cat <<-EOF
			<group>
				<action reload="true">
					<title>${1} 点击安装${MODVERSION}版本</title>
					<set>
						if [[ ! -f ${TEMP_DIR}/${MODVERSION}.zip ]]; then
							which lanzou >/dev/null
							if [[ \$? -ne 0 ]]; then
								echo '-蓝奏api不存在，访问蓝奏云链接手动安装'
								echo ${MODURL}
								exit
							fi
							echo '-下载中,稍等'
							echo ''${MODURL}'' 2>&#38;1
							lanzou ${MODURL##*/} ${TEMP_DIR}/${MODVERSION}.zip ${MODMD5}
						fi
						md5sum ${TEMP_DIR}/${MODVERSION}.zip | grep ${MODMD5} >/dev/null
						if [[ \$? -eq 0 ]]; then
							echo '-检测到'${MODVERSION}'文件,准备安装'
							if [[ -f /data/adb/magisk/magisk64 ]]; then
								alias magisk=/data/adb/magisk/magisk64
								magisk --install-module ${TEMP_DIR}/${MODVERSION}.zip
								if [[ \$? -eq 0 ]]; then
									if [[ -f ${MODPATH}/pid ]]; then
										kill -9 $(head -n1 ${MODPATH}/pid)
										rm -f ${MODPATH}/pid
									fi
									echo '-安装完成，重新设置目录'
									UPDATE=${MODPATH/modules/modules_update}
									if [[ -d \${UPDATE} ]]; then
										rm -rf ${MODPATH}
										cp -drf \${UPDATE} ${MODDIR}
										if [[ \$? -eq 0 ]]; then
											rm -rf \${UPDATE} ${MODPATH}/update
											echo '-安装完成,准备启动'
											nohup ${MODPATH}/service.sh >/dev/null 2>&#38;1
											if [[ \$? -eq 0 ]]; then
												echo '-启动成功'
											else
												echo '-启动失败'
											fi
										else
											echo '-目录设置失败，直接重启使用'
										fi
									else
										echo '-未找到更新目录，直接重启使用'
									fi
								else
									echo '-安装失败'
								fi
							else
								cp -f ${TEMP_DIR}/${MODVERSION}.zip ${SDCARD_PATH}
								echo '-未找到面具二进制文件，请手动到面具app安装'
								echo '-模块安装包:'${SDCARD_PATH}'/'${MODVERSION}.zip''
							fi
						else
							rm -f ${TEMP_DIR}/${MODVERSION}.zip
							echo '-下载过程中出现问题,请重试'
						fi
					</set>
				</action>
			</group>
		EOF
	fi
	if [[ $(( $(date +%s) - 300 )) -gt $(stat -c %Y ${TEMP_DIR}/update.log) ]]; then
		curl -sL -o ${TEMP_DIR}/update.log ${LOGURL}
	fi
	cat <<-EOF
		<group>
			<text>
				<slice u="true" align="center" break="true" link="https://gitee.com/qiuleyo/wen_kong_app/" size="20">点击访问项目开源地址</slice>
			</text>
		</group>
		<group>
			<text>
				<slice align="left" break="true" size="20">更新日志:</slice>
				<slice break="true" size="15" color="#ff6800">&#x000A;$(cat ${TEMP_DIR}/update.log | sed ':a;N;$!ba; s/\n/\&#x000A;/g')</slice>
			</text>
		</group>
	EOF
	exit
}
function md5check(){
	md5sum "${MODPATH}/${1}" | egrep "${2}" >/dev/null
	if [[ $? -ne 0 ]]; then
		download fix $@
	fi
}

if [[ ${PACKAGE_NAME} != com.fuckwenkong ]]; then
	cat <<-EOF
		<text>
			<slice bold="true" align="center" size="20">非正版管理器，请勿用此版本反馈bug</slice>
		</text>
	EOF
else
	if [[ ${PACKAGE_VERSION_CODE} != 202110081 ]]; then
		cat <<-EOF
			<text>
				<slice u="true" align="center" break="true" link="https://www.lanzouw.com/i1Rmov23l8f" size="20">管理器不是最新版&#x000A;点击获取最新管理器下载链接</slice>
			</text>
		EOF
	else
		md5sum $(pm path com.fuckwenkong | sed "s/package://g") | grep 58ec8a6adb152cb86efa83ec0f5bc0fe >/dev/null
		if [[ $? -ne 0 ]]; then
			cat <<-EOF
				<text>
					<slice bold="true" align="center" size="20">管理器遭到篡改，请勿用此版本反馈bug</slice>
				</text>
			EOF
		fi
	fi
fi

if [ -d "${MODPATH}" ];then
	PROP="${MODPATH}/module.prop"
	LOG="${MODPATH}/service.log"
	DISABLE="${MODPATH}/disable"
	SERVICE="${MODPATH}/service.sh"
	WM="${MODPATH}/水印.png"
	list_wait=${MODPATH}/list_wait
	list_finish=${MODPATH}/list_finish
	list_path=${MODPATH}/list_path
	source "${PROP}"
	[[ ${version} == ${MODVERSION} ]] || download 模块不是最新版
	
	
else
	download 未安装模块
fi

#分享码
SHARE_FILE=${TEMP_DIR}/${shell_name}.share
if [[ -f ${SHARE_FILE} ]]; then
	SHARE="-分享码: $(cat ${SHARE_FILE} | head -n 1)"
else
	SHARE="-喜欢的模板可以分享给别人哦"
fi
if [[ ${mode} == shadow ]]; then
	TITLE="阴影截图"
else
	TITLE="带壳截图"
fi

cat <<-EOF
	<group>
		<switch shell="hidden" reload="${RELOAD}">
			<title>阴影截图(免重启模块开关)</title>
			<desc>-版本 ${version}
				-作者 ${author}
				-路径 ${MODPATH}
				-介绍 ${description}
			</desc>
			<get>
				if [[ -n &#34;$(pgrep -f ${MODPATH}/shadow)&#34; ]] || \
				[[ -n &#34;$(pgrep -f ${MODPATH}/service.sh)&#34; ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					nohup ${SERVICE} >/dev/null 2>&#38;1
				else
					[ -f ${DISABLE} ] || touch ${DISABLE}
				fi
			</set>
		</switch>
	</group>
	<group>
		<action shell="hidden" reload="true">
			<title>切换阴影/带壳</title>
			<desc>当前:${TITLE}</desc>
			<set>
				if [[ ${mode} == shadow ]]; then
					MODE='shell'
				else
					MODE='shadow'
				fi
				sed -i 's/^mode=.*/mode=&#34;'\${MODE}'&#34;/g' ${PROP}
			</set>
		</action>
	</group>

	<group>
		<action>
			<title>自选图片${TITLE}</title>
			<param
				name="FILE"
				title="选取图片"
				required="true"
				type="file"/>
			<param
				name="DIR"
				title="保存目录"
				type="folder"
				required="true"
				value-sh="find ${SDCARD_PATH}/DCIM ${SDCARD_PATH}/Pictures -name 'Screenshots' -type d | head -n 1"/>
			<param
				name="SWITCH"
				label="水印开关"
				type="switch"
				value="0"/>
			<set>
				if [[ \${SWITCH} -eq 0 ]]; then
					switch9=no
				else
					switch9=yes
				fi
				yyjt "\${FILE}" "\${DIR}"
				[[ -f ${WM} ]] &#38;&#38; rm -f ${WM}
			</set>
		</action>
EOF
if [[ ${switch6} == yes ]]; then
	if [[ -d "${screenshots_bak}" ]]; then
		BAKNUM=$(ls "${screenshots_bak}" | wc -l)
		if [[ ${BAKNUM} -ne 0 ]]; then
			cat <<-EOF
				<picker reload="${RELOAD}">
					<title>处理已备份的${BAKNUM}张截图</title>
					<options>
						<option value="delete">删除所有备份</option>
						<option value="recover">仅恢复模块处理后的图片未删除的备份</option>
						<option value="recover_all">恢复所有备份</option>
					</options>
					<get>
						echo delete
					</get>
					<set>
						PID=\$(pgrep -f "shadow_screenshots/shadow")
						if [[ -n "\${PID}" ]] &#38;&#38; [[ \${state} != delete ]]; then
							echo "检测到模块正在运行中,当前操作需暂时关闭模块" 1>&#38;2
							exit 1
						fi
						if [[ \${state} == delete ]]; then
							rm -rf "${screenshots_bak}"
						elif [[ \${state} == recover ]]; then
							for i in \$(ls ${screenshots_bak})
							do
								BAKFILE="\$(find ${screenshots} -name "\${i}" -type f | uniq)"
								if [[ -f "\${BAKFILE}" ]]; then
									mv -f "${screenshots_bak}/\${i}" "\${BAKFILE}"
									if [[ \$? -eq 0 ]]; then
										echo \${i} >> ${list_finish}
										echo "成功\${i}"
									else
										echo "失败\${i}" 1>&#38;2
									fi
								fi
							done
						elif [[ \${state} == recover_all ]]; then
							for i in \$(ls ${screenshots_bak})
							do
								mv -f "${screenshots_bak}/\${i}" "${screenshots%% *}"
								if [[ \$? -eq 0 ]]; then
									echo \${i} >> ${list_finish}
									echo "成功\${i}"
								else
									echo "失败\${i}" 1>&#38;2
								fi
							done
						else
							echo "必须要选一个哦" 1>&#38;2
						fi
					</set>
				</picker>
			EOF
		fi
	fi
fi
cat <<-EOF
		<action>
			<title>查看当前详细配置</title>
			<set>
				cat ${PROP}
			</set>
		</action>
EOF
if [[ -f ${LOG} ]]; then
	cat <<-EOF
		<action>
			<title>查看最近一千条log记录</title>
			<set>
				tail -n 1000 ${LOG}
			</set>
		</action>
	EOF
else
	cat <<-EOF
		<action shell="hidden">
			<title>模块遇到未知问题，log已丢失</title>
		</action>
	EOF
fi
cat <<-EOF
	</group>
EOF
if [[ ${mode} == shell ]]; then
	cat <<-EOF
		<group title="带壳设置">
			<page
				icon="${START_DIR}/png/${shell_name}.png"
				title="带壳截图模板"
				desc="-当前: ${shell_name}&#x000A;${SHARE}"
				before-load="[[ \$(( $(date +%s) - 300 )) -gt \$(stat -c %Y \${PAGE}/shell_download.sh) ]] &#38;&#38; curl -o ${PAGE}/shell_download.sh -sL https://ak47biubiubiu.coding.net/p/pio/d/pio/git/raw/master/page/shell_download.sh"
				config-sh="source ${PAGE}/shell_download.sh"/>
			<picker shell="hidden">
				<title>带壳截图横屏时图片旋转方向</title>
				<options>
					<option value="left">顺时针左旋转</option>
					<option value="right">逆时针右旋转</option>
				</options>
				<get>
					echo ${shell_turn}
				</get>
				<set>
					sed -i 's/^shell_turn=.*/shell_turn=&#34;'\${state}'&#34;/g' ${PROP}
				</set>
			</picker>
			<picker shell="hidden">
				<title>带壳截图横屏时壳旋转方向</title>
				<options>
					<option value="left">顺时针左旋转</option>
					<option value="right">逆时针右旋转</option>
					<option value="default">不旋转</option>
				</options>
				<get>
					echo ${shell_turn2}
				</get>
				<set>
					sed -i 's/^shell_turn2=.*/shell_turn2=&#34;'\${state}'&#34;/g' ${PROP}
				</set>
			</picker>
	EOF
else
	cat <<-EOF
		<group title="阴影设置">
			<switch shell="hidden" reload="${RELOAD}">
				<title>深色模式反转边缘阴影</title>
				<get>
					if [[ ${switch2} == yes ]]; then
						echo 1
					else
						echo 0
					fi
				</get>
				<set>
					if [ \${state} -eq 1 ]; then
						sed -i 's/^switch2=.*/switch2=&#34;yes&#34;/g' ${PROP}
					else
						sed -i 's/^switch2=.*/switch2=&#34;no&#34;/g' ${PROP}
					fi
				</set>
			</switch>
			<action shell="hidden">
				<title>圆角值半径</title>
				<param
					name="ROUND"
					type="seekbar"
					min="1"
					max="100"
					value="${round}"/>
				<set>
					sed -i 's/^round=.*/round=&#34;'\${ROUND}'&#34;/g' ${PROP}
				</set>
			</action>
			<action shell="hidden">
				<title>原图在生成后的图片中占比</title>
				<param
					name="DIMEN"
					type="seekbar"
					min="1"
					max="100"
					value="${dimen%\%}"/>
				<set>
					sed -i 's/^dimen=.*/dimen=&#34;'\${DIMEN}'%&#34;/g' ${PROP}
				</set>
			</action>
			<action shell="hidden">
				<title>原图周围阴影颜色</title>
				<param
					name="COLOR"
					title="不允许透明度，设置透明度会自动删去，RRGGBB"
					type="color"
					value="${color}"/>
				<set>
					COLOR=#\${COLOR:0-6}
					sed -i 's/^color=.*/color=&#34;'\${COLOR}'&#34;/g' ${PROP}
				</set>
			</action>
			<action shell="hidden">
				<title>阴影截图背景</title>
				<param
					name="SHADOW_BG"
					title="输入图片绝对路径或者#RGB"
					type="file"
					editable="true"
					required="true"
					value="${shadow_bg}"/>
				<set>
					sed -i 's@^shadow_bg=.*@shadow_bg=&#34;'\${SHADOW_BG}'&#34;@g' ${PROP}
				</set>
			</action>
	EOF
fi
cat <<-EOF
		<switch shell="hidden" reload="${RELOAD}">
			<title>使用原图做背景</title>
			<get>
				if [[ ${switch10} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch10=.*/switch10=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch10=.*/switch10=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<action reload="${RELOAD}" shell="hidden">
			<title>背景模糊策略</title>
			<param
				name="BG"
				title="旧版高斯模糊"
				type="seekbar"
				min="0"
				max="50"
				value="${bg##*x}"/>
			<param
				name="SWITCH8"
				label="使用新的模糊方案"
				type="switch"
				value-sh="[[ ${switch8} == yes ]] &#38;&#38; echo 1 || echo 0"/>
			<param
				name="ZOOM"
				title="新模糊方案缩放数值"
				type="seekbar"
				min="10"
				max="300"
				value="${zoom}"/>
			<set>
				sed -i 's/^bg=.*/bg=&#34;-blur 0x'\${BG}'&#34;/g' ${PROP}
				if [[ \${SWITCH8} == 1 ]]; then
					sed -i 's/^switch8=.*/switch8=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch8=.*/switch8=&#34;no&#34;/g' ${PROP}
				fi
				sed -i 's/^zoom=.*/zoom=&#34;'\${ZOOM}'&#34;/g' ${PROP}
			</set>
		</action>
	</group>

	<group title="模块设置">
		<action shell="hidden">
			<title>监听目录选择</title>
			<param
				name="SHOTSPATH"
				title="多个目录手动输入空格隔开"
				type="folder"
				editable="true"
				value="${screenshots}"/>
			<set>
				SHOTSPATH=\$(echo \${SHOTSPATH} | sed 's/ *$//g')
				sed -i 's#^screenshots=.*#screenshots=&#34;'\${SHOTSPATH}'&#34;#g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>完成后截图保存目录</title>
			<param
				name="SHOTSPATH"
				title="开启覆盖原图失效"
				type="folder"
				editable="true"
				value="${screenshots_shadow}"/>
			<set>
				sed -i 's#^screenshots_shadow=.*#screenshots_shadow=&#34;'\${SHOTSPATH}'&#34;#g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>分辨率设置</title>
			<param
				name="DPI"
				title="本机分辨率识别 使用此项自由填写需留空"
				option-sh="wm size | grep -oE '[0-9]+x[0-9]+'"/>
			<param
				name="DPI2"
				title="自由填写分辨率 填写后不使用自动识别"
				type="text"
				value="${WH}"/>
			<set>
				[[ -n \${DPI2} ]] &#38;&#38; DPI=\${DPI2}
				sed -i 's/^WH=.*/WH=&#34;'\${DPI}'&#34;/g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>监控图片关键字</title>
			<param
				name="FORMAT1"
				title="监控关键字 用 | 隔开"
				type="text"
				value="${format1}"/>
			<param
				name="FORMAT2"
				title="排除关键字 用 | 隔开"
				type="text"
				value="${format2}"/>
			<set>
				sed -i 's/^format1=.*/format1=&#34;'\${FORMAT1}'&#34;/g' ${PROP}
				sed -i 's/^format2=.*/format2=&#34;'\${FORMAT2}'&#34;/g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>生成图片格式</title>
			<param
				name="FORMAT"
				value="${format3}"
				options-sh="echo -e 'jpg\njpeg\npng\nraw'"/>
			<set>
				sed -i 's/^format3=.*/format3=&#34;'\${FORMAT}'&#34;/g' ${PROP}
			</set>
		</action>
		<switch shell="hidden" reload="${RELOAD}">
			<title>是否覆盖原图</title>
			<get>
				if [[ ${switch1} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch1=.*/switch1=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch1=.*/switch1=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<action shell="hidden">
			<title>备份原图</title>
			<param
				name="SWITCH6"
				label="开启原图备份"
				type="switch"
				value-sh="[[ ${switch6} == yes ]] &#38;&#38; echo 1 || echo 0"/>
			<param
				name="FILE"
				title="备份目录选择"
				type="folder"
				editable="true"
				value="${screenshots_bak}"/>
			<set>
				if [[ \${SWITCH6} == 1 ]]; then
					sed -i 's/^switch6=.*/switch6=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch6=.*/switch6=&#34;no&#34;/g' ${PROP}
				fi
				sed -i 's#^screenshots_bak=.*#screenshots_bak=&#34;'\${FILE}'&#34;#g' ${PROP}
			</set>
		</action>
		<switch shell="hidden" reload="${RELOAD}">
			<title>图片处理完成后刷新相册</title>
			<get>
				if [[ ${switch4} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch4=.*/switch4=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch4=.*/switch4=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
	</group>

	<group title="运行设置">
		<action shell="hidden">
			<title>休眠规则</title>
			<param
				name="XM1"
				title="修改现有规则 未勾选的规则确认后将会删除"
				multiple="true"
				separator=" "
				value-sh="sed -n '/^[ 	]*t[0-9]*=/p' ${PROP} | grep -oE '[0-9:]*-[0-9:]*' | tr '\n' ' '"
				options-sh="sed -n '/^[ 	]*t[0-9]*=/p' ${PROP} | grep -oE '[0-9:]*-[0-9:]*'"/>
			<param
				name="XM2"
				title="添加新的规则 多个规则另起一行或空格隔开"
				type="text"
				placeholder="格式00:00-00:00 例9:30-13:30"/>
			<set>
				i=1
				sed -i '/^[ 	]*t[0-9]*=/d' ${PROP}
				for j in \${XM1} \${XM2}
				do
					sed -i '/#休眠标识行/a\ t'\${i}'=&#34;'\${j}'&#34;' ${PROP}
					i=\$(( \${i} + 1 ))
				done
			</set>
		</action>
		<action shell="hidden">
			<title>运行时间间隔</title>
			<param
				name="TIME1"
				title="亮屏间隔 时间越短处理越及时"
				type="seekbar"
				min="1"
				max="60"
				value="${time1}"/>
			<param
				name="TIME2"
				title="息屏间隔 点亮屏幕后也要等到上一个间隔结束"
				type="seekbar"
				min="1"
				max="300"
				value="${time2}"/>
			<set>
				sed -i 's/^time1=.*/time1=&#34;'\${TIME1}'&#34;/g' ${PROP}
				sed -i 's/^time2=.*/time2=&#34;'\${TIME2}'&#34;/g' ${PROP}
			</set>
		</action>
		<switch shell="hidden" reload="${RELOAD}">
			<title>开启log记录</title>
			<get>
				if [[ ${switch5} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch5=.*/switch5=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch5=.*/switch5=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<switch shell="hidden" reload="${RELOAD}">
			<title>关键log吐司通知</title>
			<get>
				if [[ ${toast} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^toast=.*/toast=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^toast=.*/toast=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<switch shell="hidden" reload="${RELOAD}">
			<title>勿扰挂起</title>
			<get>
				if [[ ${switch7} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch7=.*/switch7=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch7=.*/switch7=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
	</group>

	<group title="水印设置">
		<switch shell="hidden" reload="${RELOAD}">
			<title>水印开关</title>
			<get>
				if [[ ${switch9} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^switch9=.*/switch9=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^switch9=.*/switch9=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<action shell="hidden">
			<title>水印模板设置</title>
			<param
				name="WATERMARK"
				title="水印内容"
				type="text"
				value="
EOF
echo "${watermark}" | while read line
do
	[ -n "${line}" ] && echo "${line}&#x000A;"
done
cat <<-EOF
				"/>
			<set>
				if [ `sed -n '/^watermark=/p' ${PROP} | grep -o '&#34;' | wc -l` -gt 1 ]; then
					sed -i '/^watermark/d' ${PROP}
				else
					sed -i '/^watermark/,/&#34;/d' ${PROP}
				fi
				echo 'watermark=&#34;' > ${WM}
				echo &#34;\${WATERMARK}&#34; >> ${WM}
				echo '&#34;' >> ${WM}
				sed -i '/^$/d' ${WM}
				sed -i &#34;/^#水印标识行/r${WM}&#34; ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>网络连接超时</title>
			<param
				name="timeout"
				type="seekbar"
				min="0"
				max="200"
				value="${timeout}"/>
			<set>
				sed -i 's/^timeout=.*/timeout=&#34;'\${timeout}'&#34;/g' ${PROP}
			</set>
		</action>
		<switch shell="hidden" reload="${RELOAD}">
			<title>水印实时刷新</title>
			<get>
				if [[ ${refresh} == yes ]]; then
					echo 1
				else
					echo 0
				fi
			</get>
			<set>
				if [ \${state} -eq 1 ]; then
					sed -i 's/^refresh=.*/refresh=&#34;yes&#34;/g' ${PROP}
				else
					sed -i 's/^refresh=.*/refresh=&#34;no&#34;/g' ${PROP}
				fi
			</set>
		</switch>
		<action shell="hidden">
			<title>水印位置</title>
			<param
				name="PLAN"
				title="水印内容对齐"
				value="${plan}">
				<option value="west">左侧对齐</option>
				<option value="center">水平居中</option>
				<option value="east">右侧对齐</option>
			</param>
			<param
				name="LOCATION"
				title="水印要添加的位置"
				value="${location}">
				<option value="northwest">左上</option>
				<option value="north">上中</option>
				<option value="northeast">右上</option>
				<option value="west">左中</option>
				<option value="center">正中</option>
				<option value="east">右中</option>
				<option value="southwest">左下</option>
				<option value="south">下中</option>
				<option value="southeast">右下</option>
			</param>
			<param
				name="H"
				title="水印到水平边缘的距离"
				type="seekbar"
				min="0"
				max="200"
				value="${range_h}"/>
			<param
				name="V"
				title="水印到垂直边缘的距离"
				type="seekbar"
				min="0"
				max="200"
				value="${range_v}"/>
			<set>
				sed -i 's/^plan=.*/plan=&#34;'\${PLAN}'&#34;/g' ${PROP}
				sed -i 's/^location=.*/location=&#34;'\${LOCATION}'&#34;/g' ${PROP}
				sed -i 's/^range_h=.*/range_h=&#34;'\${H}'&#34;/g' ${PROP}
				sed -i 's/^range_v=.*/range_v=&#34;'\${V}'&#34;/g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>单个水印最大宽高</title>
			<param
				name="DIMEN1"
				title="文字大小"
				type="seekbar"
				min="1"
				max="200"
				value="${wm_dimen}"/>
			<param
				name="DIMEN2"
				title="图片大小"
				type="seekbar"
				min="1"
				max="200"
				value="${wm_dimen2}"/>
			<set>
				sed -i 's/^wm_dimen=.*/wm_dimen=&#34;'\${DIMEN1}'&#34;/g' ${PROP}
				sed -i 's/^wm_dimen2=.*/wm_dimen2=&#34;'\${DIMEN2}'&#34;/g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>水印颜色</title>
			<param
				name="COLOR2"
				title="水印字体颜色，不允许透明度，设置透明度会自动删去，RRGGBB"
				type="color"
				value="${color2}"/>
			<param
				name="COLOR3"
				title="字体阴影颜色，不允许透明度，设置透明度会自动删去，RRGGBB"
				type="color"
				value="${color3}"/>
			<set>
				COLOR2=#\${COLOR2:0-6}
				COLOR3=#\${COLOR3:0-6}
				sed -i 's/^color2=.*/color2=&#34;'\${COLOR2}'&#34;/g' ${PROP}
				sed -i 's/^color3=.*/color3=&#34;'\${COLOR3}'&#34;/g' ${PROP}
			</set>
		</action>
		<action shell="hidden">
			<title>水印字体</title>
			<param
				name="FONT"
				title="系统字体在/system/fonts下，可以手动输入"
				type="file"
				editable="true"
				value="${font}"/>
			<set>
				sed -i 's#^font=.*#font=&#34;'\${FONT}'&#34;#g' ${PROP}
			</set>
		</action>
	</group>

	<group>
		<text>
			<slice u="true" align="center" break="true" link="${MODURL}" size="20">点击获取${MODVERSION}版本下载链接&#x000A;其他版本设置出问题不负责</slice>
		</text>
	</group>
	<group>
		<text>
			<slice u="true" align="center" break="true" link="https://gitee.com/youngdriver/shadow_screenshots" size="20">点击访问项目开源地址</slice>
		</text>
	</group>
	<group visible="ls /storage/emulated/*/Android/data/com.tencent.mobileqq/Tencent/MobileQQ/head/_hd/troop_5C9011F14FE9DEB5175FF2B43674ECC4.jpg_ &#38;&#38; echo 0 || echo 1">
		<text>
			<slice u="true" align="center" break="true" link="mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3DB_Fye86VlQjJdfSX2Wcv2wG4vmvBYSFv" size="20">点击访问阿巴群</slice>
		</text>
	</group>
EOF