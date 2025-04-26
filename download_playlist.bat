@echo off

:: Here the playlist will be downloaded
set destination=%USERPROFILE%\Videos

:: Ask for the YouTube playlist URL
set /p playlist_url="Enter the YouTube playlist URL: "

:: Ask for the desired resolution
set /p resolution="Enter the resolution (e.g., 1080, 720, 480): "

:: Ask for the starting video number in the playlist
set /p start_video="Enter the starting video number in the playlist (default is 1): "

:: Set default value if the user does not enter anything
if "%start_video%"=="" set start_video=1

:: Run yt-dlp with user-specified resolution and starting point using modern options
set optional_params=--playlist-items %start_video%- --cookies cookies.txt --no-part --quiet --progress --no-warnings --console-title
set output_template=-o "%destination%/%%(playlist_title)s/%%(playlist_index)s - %%(title)s.%%(ext)s"
set format=-f "bv[height<=%resolution%]+bestaudio"
yt-dlp %format% %optional_params% %output_template% %playlist_url%

pause