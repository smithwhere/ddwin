@ECHO OFF
::网址：nat.ee
::批处理：荣耀&制作 QQ:1800619
>NUL 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
IF '%errorlevel%' NEQ '0' (
GOTO UACPrompt
) ELSE ( GOTO gotAdmin )
:UACPrompt
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
EXIT /B
:gotAdmin
IF EXIST "%temp%\getadmin.vbs" ( DEL "%temp%\getadmin.vbs" )
title nat.ee
mode con: cols=32 lines=12
color 17
:menu
CLS
ECHO           NTP时间同步
ECHO.
SET Parameters=HKLM\SYSTEM\CurrentControlSet\services\W32Time\Parameters
SET NtpClient=HKLM\SYSTEM\CurrentControlSet\services\W32Time\TimeProviders\NtpClient
::删除服务配置信息
SET "scte=sc triggerinfo w32time delete > NUL"
::创建服务默认配置
SET "sctd=sc triggerinfo w32time start/domainjoin > NUL"
::创建服务配置：联网启动/不联网停止
SET "sctn=sc triggerinfo w32time start/networkon stop/networkoff > NUL"
::设置服务模式：自动运行
SET "scca=sc config W32Time start= auto > NUL"
::设置服务模式：手动运行
SET "sccd=sc config W32Time start= demand > NUL"
::启动服务
SET "sa=net start w32time 2>NUL"
::停止服务
SET "so=net stop w32time 2>NUL"
for /f "skip=1 tokens=3* delims=, " %%i in ('REG QUERY "%Parameters%" /v "NtpServer"') DO (SET address=%%i)
for /f %%s in ('wmic service where "name='w32time'" get state^|findstr /c:"Stopped" /c:"Running" /c:"Paused"') DO (SET servicestatus=%%s)
IF "%servicestatus%" == "Running" (ECHO Time状态：运行)
IF "%servicestatus%" == "Stopped" (ECHO Time状态：停止)
IF "%servicestatus%" == "Paused" (ECHO Time状态：暂停)
ECHO NTP地址：%address%
ECHO.
ECHO 1.启动
ECHO 2.重启
ECHO 3.终止
ECHO 4.设置
ECHO 5.退出
ECHO.
choice /C:12345 /N /M "请输入你的选择 [1,2,3,4,5]"：
if errorlevel 5 EXIT
if errorlevel 4 GOTO:config
if errorlevel 3 GOTO:stop
if errorlevel 2 GOTO:restart
if errorlevel 1 GOTO:start
::启动
:start
CLS
%scte%
%sctn%
%scca%
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "1" /f  > nul
%sa%
TIMEOUT 3 >NUL
GOTO:menu

::重启
:restart
CLS
%scte%
%sctn%
%scca%
%so%
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "1" /f  > nul
%sa%
TIMEOUT 3 >NUL
GOTO:menu

::终止
:stop
CLS
%scte%
%sctd%
%sccd%
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "0" /f  > nul
%so%
TIMEOUT 3 >NUL
GOTO:menu

::设置
:config
CLS
ECHO 1.设置NTP服务器(域名/IP)地址
ECHO 留空默认ntp1.aliyun.com
ECHO 输入地址，按回车(Enter)
ECHO.
set /p NtpServer=地址：
IF "%NtpServer%" == "" (
ECHO 使用默认 ntp1.aliyun.com
set NtpServer=ntp1.aliyun.com
TIMEOUT 3 >NUL
)
CLS
ECHO 2.设置时间同步更新间隔
ECHO 留空默认3600秒(1小时)
ECHO 输入(多少秒)，按回车(Enter)
ECHO.
set /p SpecialPollInterval=数值(秒)：
IF "%SpecialPollInterval%" == "" (
ECHO 使用默认3600秒
set SpecialPollInterval=3600
TIMEOUT 3 >NUL
)
Reg add "%Parameters%" /v "Type" /t REG_SZ /d "NTP" /f  > NUL
Reg add "%Parameters%" /v "NtpServer" /t REG_SZ /d "%NtpServer%,0x1" /f  > NUL
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "1" /f  > nul
Reg add "%NtpClient%" /v "CrossSiteSyncFlags" /t REG_DWORD /d "2" /f  > NUL
Reg add "%NtpClient%" /v "EventLogFlags" /t REG_DWORD /d "0" /f  > NUL
Reg add "%NtpClient%" /v "ResolvePeerBackoffMinutes" /t REG_DWORD /d "15" /f  > NUL
Reg add "%NtpClient%" /v "ResolvePeerBackoffMaxTimes" /t REG_DWORD /d "7" /f  > NUL
Reg add "%NtpClient%" /v "SpecialPollInterval" /t REG_DWORD /d "%SpecialPollInterval%" /f  > NUL
CLS
%scte%
%sctn%
%scca%
%so%
%sa%
ECHO 完成。
TIMEOUT 3 >NUL
GOTO:menu
EXIT