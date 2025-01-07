import os
import subprocess
import pyperclip
from urllib.parse import parse_qs, urlparse

def main():
    # Get URL from clipboard
    url = pyperclip.paste().strip()
    if not url:
        print("[Error] Clipboard is empty. Please copy a valid YouTube video or playlist URL.")
        return

    # print(f"URL: {url}")

    # Detect URL type (playlist or video)
    if is_playlist(url):
        print("[Info] Detected as a playlist URL.")
        download_playlist(url)
    else:
        # print("[Info] Detected as a video URL.")
        download_video(url)

def is_playlist(url):
    query = urlparse(url)[4]
    params = parse_qs(query)
    if params.get("v"): return False
    return "list" in params

def download_playlist(url):
    destination = os.path.join(os.path.expanduser("~"), "Videos")
    resolution = input("Enter the resolution (e.g., 1080, 720, 480): ").strip()
    start_video = input("Enter the starting video number in the playlist (default is 1): ").strip() or "1"

    command = [
        "yt-dlp",
        f"-f bv[height<={resolution}]+bestaudio/best",
        "--playlist-items", f"{start_video}-",
        "--cookies", "cookies.txt",
        "--no-part",
        "--quiet",
        "--progress",
        "--no-warnings",
        "--console-title",
        "--exec", "before_dl:echo 'Downloading: %(playlist_index)s'",
        "-o", f"{destination}/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s",
        url
    ]

    run_command(command, "playlist")

def download_video(url):
    common_params = [
        "--quiet",
        "--no-warnings",
        "--no-playlist",
        "--cookies", "cookies.txt"
    ]
    download_params = [
        "--ignore-no-formats-error",
        "--progress",
        "--console-title",
        "--no-part",
        "-o", os.path.join(os.path.expanduser("~"), "Videos", "%(title)s.%(ext)s")
    ]

    print("[Info] Fetching available formats...")
    list_formats_command = ["yt-dlp", "--list-formats"] + common_params + [url]
    run_command(list_formats_command, "fetch formats")

    format_code = input("Enter the format code (e.g., video_id+audio_id): ").strip()
    command = ["yt-dlp", "-f", format_code] + common_params + download_params + [url]

    run_command(command, "video")

def run_command(command, action):
    try:
        subprocess.run(command, check=True)
        # print(f"[Success] {action.capitalize()} downloaded successfully!")
    except subprocess.CalledProcessError:
        print(f"[Error] Failed to download the {action}. Please check the URL.")

if __name__ == "__main__":
    main()