where /q powershell || echo powershell not found && exit /b

REM solve the `luatex.dll not found` error
powershell -Command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('luatex.zip', '.'); }"
set path=%PATH%;"%~dp0luatex"

REM rem switch to a temp directory, whichever works
mkdir tmp
cd /d tmp
xcopy /y ..\install-tl.zip .\

powershell -Command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('install-tl.zip', '.'); }"
del install-tl.zip

xcopy /y ..\tinytex.profile .\
powershell -Command "(gc tinytex.profile) -replace '\./', './TinyTex/' | Out-File -encoding ASCII tinytex.profile"

echo TEXMFCONFIG $TEXMFSYSCONFIG>> tinytex.profile
echo TEXMFHOME $TEXMFLOCAL>> tinytex.profile
echo TEXMFVAR $TEXMFSYSVAR>> tinytex.profile

xcopy /y ..\pkgs-custom.txt .\

rem an automated installation of TeXLive (infrastructure only)
cd install-tl-*
REM move /y C:\Users\zwhvi\Downloads\luatex.dll .\texmf-dist\scripts\texlive
@echo | install-tl-windows.bat -no-gui -profile=../tinytex.profile

del TinyTeX\install-tl.log ..\tinytex.profile

rem TeXLive installed to ./TinyTeX; move it to APPDATA
rd /s /q "%APPDATA%\TinyTeX"
rd /s /q "%APPDATA%\TinyTeX"
move /y TinyTeX "%APPDATA%"

rem clean up the install-tl-* directory
cd ..
for /d %%G in ("install-tl-*") do rd /s /q "%%~G"

rem install all custom packages
@echo off
setlocal enabledelayedexpansion
set "pkgs="
for /F %%a in (pkgs-custom.txt) do set "pkgs=!pkgs! %%a"
@echo on

del pkgs-custom.txt

call "%APPDATA%\TinyTeX\bin\win32\tlmgr" path add
call "%APPDATA%\TinyTeX\bin\win32\tlmgr" install latex-bin xetex %pkgs%

rem del luatex
cd ..
rd /s /q luatex
rd /s /q tmp

rem Create TinyTex.iso for portable
oscdimg.exe -u2 -h -k -m -lTinyTex -w1 %APPDATA%\TinyTex .\TinyTex.iso

pause
