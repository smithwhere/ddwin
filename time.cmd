@ECHO OFF
::��ַ��nat.ee
::��������ҫ&���� QQ:1800619
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
ECHO           NTPʱ��ͬ��
ECHO.
SET Parameters=HKLM\SYSTEM\CurrentControlSet\services\W32Time\Parameters
SET NtpClient=HKLM\SYSTEM\CurrentControlSet\services\W32Time\TimeProviders\NtpClient
::ɾ������������Ϣ
SET "scte=sc triggerinfo w32time delete > NUL"
::��������Ĭ������
SET "sctd=sc triggerinfo w32time start/domainjoin > NUL"
::�����������ã���������/������ֹͣ
SET "sctn=sc triggerinfo w32time start/networkon stop/networkoff > NUL"
::���÷���ģʽ���Զ�����
SET "scca=sc config W32Time start= auto > NUL"
::���÷���ģʽ���ֶ�����
SET "sccd=sc config W32Time start= demand > NUL"
::��������
SET "sa=net start w32time 2>NUL"
::ֹͣ����
SET "so=net stop w32time 2>NUL"
for /f "skip=1 tokens=3* delims=, " %%i in ('REG QUERY "%Parameters%" /v "NtpServer"') DO (SET address=%%i)
for /f %%s in ('wmic service where "name='w32time'" get state^|findstr /c:"Stopped" /c:"Running" /c:"Paused"') DO (SET servicestatus=%%s)
IF "%servicestatus%" == "Running" (ECHO Time״̬������)
IF "%servicestatus%" == "Stopped" (ECHO Time״̬��ֹͣ)
IF "%servicestatus%" == "Paused" (ECHO Time״̬����ͣ)
ECHO NTP��ַ��%address%
ECHO.
ECHO 1.����
ECHO 2.����
ECHO 3.��ֹ
ECHO 4.����
ECHO 5.�˳�
ECHO.
choice /C:12345 /N /M "���������ѡ�� [1,2,3,4,5]"��
if errorlevel 5 EXIT
if errorlevel 4 GOTO:config
if errorlevel 3 GOTO:stop
if errorlevel 2 GOTO:restart
if errorlevel 1 GOTO:start
::����
:start
CLS
%scte%
%sctn%
%scca%
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "1" /f  > nul
%sa%
TIMEOUT 3 >NUL
GOTO:menu

::����
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

::��ֹ
:stop
CLS
%scte%
%sctd%
%sccd%
Reg add "%NtpClient%" /v "Enabled" /t REG_DWORD /d "0" /f  > nul
%so%
TIMEOUT 3 >NUL
GOTO:menu

::����
:config
CLS
ECHO 1.����NTP������(����/IP)��ַ
ECHO ����Ĭ��time.asia.apple.com
ECHO �����ַ�����س�(Enter)
ECHO.
set /p NtpServer=��ַ��
IF "%NtpServer%" == "" (
ECHO ʹ��Ĭ�� time.asia.apple.com
set NtpServer=time.asia.apple.com
TIMEOUT 3 >NUL
)
CLS
ECHO 2.����ʱ��ͬ�����¼��
ECHO ����Ĭ��3600��(1Сʱ)
ECHO ����(������)�����س�(Enter)
ECHO.
set /p SpecialPollInterval=��ֵ(��)��
IF "%SpecialPollInterval%" == "" (
ECHO ʹ��Ĭ��3600��
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
ECHO ��ɡ�
TIMEOUT 3 >NUL
GOTO:menu
EXIT