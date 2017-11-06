NET SESSION
IF %ERRORLEVEL% NEQ 0 GOTO ELEVATE
GOTO ADMINTASKS

:ELEVATE
CD /d %~dp0
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '%CD%', '', 'runas', 1);close();"
EXIT

:ADMINTASKS

CD %~dp0
ECHO @OFF
CLS
type %CD%\src\help\welcome_message.txt
CD %CD%\src\guest
@"powershell.exe" -executionpolicy bypass




