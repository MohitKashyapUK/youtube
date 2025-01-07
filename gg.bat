@echo off
setlocal enabledelayedexpansion

:: Clipboard se URL lena
for /f "usebackq delims=" %%a in (`powershell -command "Get-Clipboard"`) do set "url=%%a"

:: URL check karna
echo Clipboard URL: %url%

echo Checking if URL is a playlist...
echo %url% | find "list=" >nul
if not errorlevel 1 (
    echo Playlist URL detected.
    call download_playlist.bat
    goto end
)

echo Checking if URL is a video...
echo %url% | findstr /r "watch\? youtu.be/" >nul
if not errorlevel 1 (
    echo Video URL detected.
    call download_video.bat
    goto end
)

echo No valid YouTube URL detected.

:end
pause