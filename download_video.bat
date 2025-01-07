@echo off

:: Define common yt-dlp parameters
set COMMON_PARAMS=--quiet --no-warnings --no-playlist --cookies cookies.txt
set DOWNLOAD_PARAMS=--ignore-no-formats-error --progress --console-title --no-part -o "%USERPROFILE%/Videos/%%(title)s.%%(ext)s"

:: Check if yt-dlp is installed
yt-dlp --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] yt-dlp is not installed or not in PATH. Please install it first.
    pause
    exit /b
)

:: Get video URL from user
set /p videoURL="Enter the video URL: "

:: List available formats
echo [Info] Fetching available formats...
yt-dlp --list-formats %COMMON_PARAMS% "%videoURL%"
if %errorlevel% neq 0 (
    echo [Error] Failed to fetch formats. Please check the URL.
    pause
    exit /b
)

:: Ask user to select a format
set /p formatCode="Enter the ID you want to download (video_id+audio_id): "

:: Download the selected format(s)
yt-dlp -f %formatCode% %COMMON_PARAMS% %DOWNLOAD_PARAMS% "%videoURL%"
if %errorlevel% neq 0 (
    echo [Error] Failed to download the video. Please check the format code.
    pause
    exit /b
)

echo [Success] Video downloaded successfully!
pause