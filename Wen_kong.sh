#!/data/user/0/com.fuckwenkong/files/busybox/toolkit/sh
echo '<?xml version="1.0" encoding="utf-8"?>'
RELOAD="true"
MODDIR="/data/adb/modules"
[[ -d "${MODDIR}" ]] || MODDIR="/data/adb/lite_modules"
MODPATH="${MODDIR}/Wen_kong"
GITEE="https://gitee.com/qiuleyo/wen_kong_app/raw/master"
APPMD5="15b24450e304ade6f445c571073b8753"
LOGURL="${GITEE}/update.log"
MODURL="https://gitee.com/qiuleyo/wen_kong_app/raw/master/Wen_kongv4.6.zip"
JCURL="${GITEE}/jc.sh"
DJURL="${GITEE}/freeze.sh"
JDURL="${GITEE}/Unfreezed.sh"
MODMD5="6dad9186d4597b644e0b05eba27f52d9"
MODVERSION="v4.6"
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
							echo '-下载中,稍等'
							curl -sL -o  /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip ${MODURL}
					
							echo '-下载完成'
						md5sum /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip | grep ${MODMD5} >/dev/null
						if [[ \$? -eq 0 ]]; then
							echo '-检测到'${MODVERSION}'文件,准备安装'
							if [[ -f /data/adb/magisk/magisk64 ]]; then
								alias magisk=/data/adb/magisk/magisk64
								magisk --install-module /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip
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
											echo '-安装完成'
											rm -f /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip
											nohup ${MODPATH}/service.sh >/dev/null 2>&#38;1
											if [[ \$? -eq 0 ]]; then
												echo '-启动成功'
											else
												echo '-'
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
								cp -f /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip ${SDCARD_PATH}
								echo '-未找到面具二进制文件，请手动到面具app安装'
								echo '-模块安装包:'${SDCARD_PATH}'/'${MODVERSION}.zip''
							fi
						else
							rm -f /data/user/0/com.fuckwenkong/files/Wen_kong-${MODVERSION}.zip
							echo '-下载过程中出现问题,请重试'
						fi
					</set>
				</action>
			</group>
		EOF
	fi

	if [[ $(( $(date +%s) - 300 )) -gt $(stat -c %Y ${TEMP_DIR}/update.log) ]]; then
	curl -sL -o /data/user/0/com.fuckwenkong/files/update.log ${LOGURL}
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
				<slice break="true" size="15" color="#ff6800">&#x000A;$(cat /data/user/0/com.fuckwenkong/files/update.log | sed ':a;N;$!ba; s/\n/\&#x000A;/g')</slice>
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
	if [[ ${PACKAGE_VERSION_CODE} != 12 ]]; then
		cat <<-EOF
			<text>
				<slice u="true" align="center" break="true" link="https://gitee.com/qiuleyo/wen_kong_app/raw/master/APP1.1.apk" size="20">管理器不是最新版&#x000A;点击获取最新APP下载链接</slice>
			</text>
		EOF
	else
		md5sum $(pm path com.fuckwenkong | sed "s/package://g") | grep ${APPMD5} >/dev/null
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

	curl -sL -o /data/user/0/com.fuckwenkong/files/jc.sh ${JCURL}
 	curl -sL -o /data/user/0/com.fuckwenkong/files/freeze.sh ${DJURL}
	curl -sL -o /data/user/0/com.fuckwenkong/files/Unfreezed.sh ${JDURL}
cat <<-EOF
	<group>
	<action  reload="${RELOAD}">
			<title>Wen_kong</title>
			<desc>-版本 ${version}
				-作者 ${author}
				-路径 ${MODPATH}
				-介绍 ${description}
			</desc>
			
		</action>
	</group>
	<group>
		<action>
			<title>冻结云控</title>
			<set>
				source /data/user/0/com.fuckwenkong/files/freeze.sh
			</set>
		</action>
	</group>
	<group>
		<action>
			<title>解冻云控</title>
			<set>
				source /data/user/0/com.fuckwenkong/files/Unfreezed.sh
			</set>
		</action>
	</group>
EOF

cat <<-EOF
		<action>
			<title>检查温控</title>
			<set>
			source /data/user/0/com.fuckwenkong/files/jc.sh
			</set>
		</action>
EOF
cat <<-EOF
		<action>
			<title>查看当前详细配置</title>
			<set>
				cat ${PROP}
			</set>
		</action>
EOF
	<group>
		<text>
			<slice u="true" align="center" break="true" link="${MODURL}" size="20">点击获取${MODVERSION}版本下载链接&#x000A;其他版本设置出问题不负责</slice>
		</text>
	</group>
	<group>
		<text>
			<slice u="true" align="center" break="true" link="https://gitee.com/qiuleyo/wen_kong_app/tree/master" size="20">点击访问项目开源地址</slice>
		</text>
	</group>
EOF