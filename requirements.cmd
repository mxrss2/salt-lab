NET SESSION
IF %ERRORLEVEL% NEQ 0 GOTO ELEVATE
GOTO ADMINTASKS

:ELEVATE
CD /d %~dp0
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '%CD%', '', 'runas', 1);close();"
EXIT

:ADMINTASKS
cd %~dp0
type %CD%\src\help\welcome_install.txt
timeout 10

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco install git git.install invoke-build kubernetes-cli minikube vagrant -y
choco install virtualbox --version 5.1.30 -y
vagrant box add --insecure --box-version 0.1.0 mxrss2/win2k12-r2-salt
vagrant box add --insecure --box-version 0.1.0 mxrss2/linux-xental-haproxy-salt
EXIT

