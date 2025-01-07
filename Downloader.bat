@echo off

:: Check if yt-dlp is installed
yt-dlp --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] yt-dlp is not installed or not in PATH. Please install it first.
    pause
    exit /b
)

:: Fetch URL from clipboard
for /f "tokens=*" %%i in ('powershell -command "Get-Clipboard"') do set "URL=%%i"

if "%URL%"=="" (
    echo [Error] No URL found in clipboard.
    pause
    exit /b
)

:: Check if URL is a playlist
echo %URL% | find "list=" >nul
if %errorlevel% equ 0 goto download_playlist

echo %URL% | find "watch" >nul
if %errorlevel% equ 0 goto download_video

:: If neither a playlist nor a video URL
echo [Error] The provided URL is neither a valid video nor a playlist.
pause
exit /b

:download_playlist
:: Playlist download code
set destination=%USERPROFILE%\Videos

:: Ask for the desired resolution
set /p resolution="Enter the resolution (e.g., 1080, 720, 480): "

:: Ask for the starting video number in the playlist
set /p start_video="Enter the starting video number in the playlist (default is 1): "

:: Set default value if the user does not enter anything
if "%start_video%"=="" set start_video=1

:: Run yt-dlp with user-specified resolution and starting point using modern options
set optional_params=--playlist-items %start_video%- --cookies cookies.txt --no-part --quiet --progress --no-warnings --console-title
set output_template=-o "%destination%/%%(playlist_title)s/%%(playlist_index)s - %%(title)s.%%(ext)s"
set format=-f "bv[height<=%resolution%]+bestaudio/best"
yt-dlp %format% %optional_params% %output_template% %URL%

pause
exit /b

:download_video
:: Video download code
set COMMON_PARAMS=--quiet --no-warnings --no-playlist --cookies cookies.txt
set DOWNLOAD_PARAMS=--ignore-no-formats-error --progress --console-title --no-part -o "%USERPROFILE%/Videos/%%(title)s.%%(ext)s"

:: List available formats
echo [Info] Fetching available formats...
yt-dlp --list-formats %COMMON_PARAMS% "%URL%"
if %errorlevel% neq 0 (
    echo [Error] Failed to fetch formats. Please check the URL.
    pause
    exit /b
)

:: Ask user to select a format
set /p formatCode="Enter the ID you want to download (video_id+audio_id): "

:: Download the selected format(s)
yt-dlp -f %formatCode% %COMMON_PARAMS% %DOWNLOAD_PARAMS% "%URL%"
if %errorlevel% neq 0 (
    echo [Error] Failed to download the video. Please check the format code.
    pause
    exit /b
)

echo [Success] Video downloaded successfully!
pause
