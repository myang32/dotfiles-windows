@echo off
cd /D %~dp0
git pull

where /q z.bat
if ERRORLEVEL 1 call :addScriptsToUserPath

if "%1x"=="--forcex" goto doIt
if "%1x"=="-fx" goto doIt
set /p answer=This may overwrite existing files in your home directory. Are you sure? (y/n)
if "%answer%"=="y" goto doIt
if "%answer%"=="Y" goto doIt
goto :EOF

:doIt
if not exist "%USERPROFILE%\.vim\bundle\vundle" (
  git clone https://github.com/gmarik/vundle.git "%USERPROFILE%/.vim/bundle/vundle"
)
xcopy . "%USERPROFILE%" /EXCLUDE:excludes.txt /s /i /e /y /c
xcopy cmder\config "C:\cmder\config" /s /i /e /y /c

setlocal
:checkGvim
where /q gvim
if ERRORLEVEL 1 goto :checkVim
set VI=gvim
goto :bundleInstall
:checkVim
where /q vim
if ERRORLEVEL 1 goto :checkVi
set VI=vim
goto :bundleInstall
:checkVi
set VI=vi
:bundleInstall
%VI% +BundleInstall +qall
:doneBundle
endlocal

rem strawberry perl
where /q perl
if ERRORLEVEL 1 goto :noperl
where /q perltidy
if ERRORLEVEL 1 goto :installPerlTidy
goto :noperl
:installPerlTidy
call cpan -i Perl::Tidy
:noperl

where /q apm
if ERRORLEVEL 1 goto :noatom
if not exist %USERPROFILE%\.atom\packages\parcel (
  apm install parcel
)
:noatom

rem copy .vagrant.d to HOME/.vagrant.d or VAGRANT_HOME if defined
setlocal
if "%VAGRANT_HOME%x"=="x" set VAGRANT_HOME=%UserProfile%\.vagrant.d
if not exist "%VAGRANT_HOME%\Vagrantfile" (
  xcopy .vagrant.d "%VAGRANT_HOME%" /s /i /y
)
endlocal
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /d """%UserProfile%\.bashrc.bat""" /f
goto :EOF

:addScriptsToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;%UserProfile%\bin" /f
set PATH=%PATH%;%UserProfile%\bin
exit /b
