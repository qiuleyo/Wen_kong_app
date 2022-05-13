#!/data/user/0/com.fuckwenkong/files/busybox/toolkit/sh
echo '<?xml version="1.0" encoding="utf-8"?>'
RELOAD="true"
MODDIR="/data/adb/modules"
[[ -d "${MODDIR}" ]] || MODDIR="/data/adb/lite_modules"
MODPATH="${MODDIR}/wen_kong_app"
GITEE="https://gitee.com/qiuleyo/wen_kong_app/tree/master/"

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