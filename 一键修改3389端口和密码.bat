@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
title 修改远程端口与用户密码
mode con: cols=55 lines=10
color 17
set "ing=ping -n 5 127.0.0.1 > nul"
:Menu
cls
echo ==============================
echo.
echo 1.修改远程端口
echo.
echo 2.修改用户密码
echo.
echo 3.重启计算机
echo.
echo ==============================
choice /C:123 /N /M "请输入你的选项 [1,2,3]"：
if errorlevel 3 goto:Restart
if errorlevel 2 goto:Password
if errorlevel 1 goto:RemotePort
:RemotePort
cls
set /P "Port=自定义远程桌面端口(1-65535): "
if %Port% leq 65535 (
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" /v "PortNumber" /t REG_DWORD /d "%Port%" /f > nul
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "PortNumber" /t REG_DWORD /d "%Port%" /f > nul
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{338933891-3389-3389-3389-338933893389}" /t REG_SZ /d "v2.29|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=%Port%|Name=Remote Desktop(TCP-In)|" /f > nul
Reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /v "{338933892-3389-3389-3389-338933893389}" /t REG_SZ /d "v2.29|Action=Allow|Active=TRUE|Dir=In|Protocol=17|LPort=%Port%|Name=Remote Desktop(UDP-In)|" /f > nul
echo 修改成功
echo 请牢记，你的远程端口是: %Port% 
echo 重启计算机生效
%ing% && goto:Menu) else (echo 错误的端口，%Port% 大于所设置的范围，请在"1-65535"内。
%ing% && goto:RemotePort)
:Password
cls
echo 当前修改Administrator用户密码
set /p pwd1=请输入密码：
cls
set /p pwd2=请再次输入密码：
if "%pwd1%"=="%pwd2%" (
net user Administrator %pwd2% > nul
echo 修改成功，请牢记你的密码。
%ing% && goto:Menu)else (echo 密码错误，请重新输入。
%ing% && goto:Password)
:Restart
shutdown.exe /r /f /t 0