@echo off

:: Ensure yt-dlp is installed
yt-dlp --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] yt-dlp is not installed or not in PATH. Please install it first.
    pause
    exit /b
)

:: Fetch the URL from clipboard
for /f "usebackq tokens=* delims=" %%a in (`powershell -command "Get-Clipboard"`) do set "url=%%a"

:: Check if the URL was successfully fetched
if "%url%"=="" (
    echo [Error] No URL found in clipboard.
    echo Please copy a valid YouTube video or playlist URL to clipboard and try again.
    pause
    exit /b
)

:: Detect if the URL is for a playlist or a video
echo Checking URL type...
echo URL: %url%

echo %url% | findstr /i "list=" >nul
if %errorlevel%==0 (
    echo [Info] Detected as a playlist URL.

    :: Playlist-specific code
    set destination=%USERPROFILE%\Videos
    set /p resolution="Enter the resolution (e.g., 1080, 720, 480): "
    set /p start_video="Enter the starting video number in the playlist (default is 1): "
    if "%start_video%"=="" set start_video=1
    set optional_params=--playlist-items %start_video%- --cookies cookies.txt --no-part --quiet --progress --no-warnings --console-title
    set output_template=-o "%destination%/%%(playlist_title)s/%%(playlist_index)s - %%(title)s.%%(ext)s"
    set format=-f "bv[height<=%resolution%]+bestaudio/best"
    yt-dlp %format% %optional_params% %output_template% %url%
    if %errorlevel% neq 0 (
        echo [Error] Failed to download the playlist. Please check the URL or parameters.
        pause
        exit /b
    )
    echo [Success] Playlist downloaded successfully!
    pause
    exit /b
)

echo %url% | findstr /i "watch?v=" >nul
if %errorlevel%==0 (
    echo [Info] Detected as a video URL.

    :: Video-specific code
    set COMMON_PARAMS=--quiet --no-warnings --no-playlist --cookies cookies.txt
    set DOWNLOAD_PARAMS=--ignore-no-formats-error --progress --console-title --no-part -o "%USERPROFILE%/Videos/%%(title)s.%%(ext)s"
    echo [Info] Fetching available formats...
    yt-dlp --list-formats %COMMON_PARAMS% "%url%"
    if %errorlevel% neq 0 (
        echo [Error] Failed to fetch formats. Please check the URL.
        pause
        exit /b
    )
    set /p formatCode="Enter the ID you want to download (video_id+audio_id): "
    yt-dlp -f %formatCode% %COMMON_PARAMS% %DOWNLOAD_PARAMS% "%url%"
    if %errorlevel% neq 0 (
        echo [Error] Failed to download the video. Please check the format code.
        pause
        exit /b
    )
    echo [Success] Video downloaded successfully!
    pause
    exit /b
)

:: If the URL is neither video nor playlist
echo [Error] The URL does not appear to be a valid YouTube video or playlist URL.
pause
exit /b
