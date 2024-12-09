# Video URL
URL = input("YouTube video URL: ") # "https://www.youtube.com/watch?v=ltt7E3VdlyM"

from rich.console import Console
from rich.table import Table
from rich.text import Text
from rich import box
from yt_dlp import YoutubeDL
import subprocess

# To print with wrap
console = Console()

# Download video and audio formats using yt_dlp
with YoutubeDL({ "quiet": True, "no-warnings": True, "noplaylist": True, "skip_download": True }) as ydl:
    info = ydl.extract_info(URL, download=False)
    streams = info["formats"]
    video_formats = []
    audio_formats = []

    # Video aur audio formats ko alag karna
    for item in streams:
        if item.get("vcodec") != "none": # If format contains video
            video_formats.append(item)
        elif item.get("acodec") != "none": # If format contains audio
            audio_formats.append(item)

    # Formated video table
    video_table = Table(title="Video streams", border_style="bright_white", box=box.SQUARE_DOUBLE_HEAD)
    video_table.add_column("No.")
    video_table.add_column("Resolution")
    video_table.add_column("Filesize")
    video_table.add_column("Bitrate")
    video_table.add_column("FPS")
    video_table.add_column("Ext")
    video_table.add_column("Codec")

    # Formated audio table
    audio_table = Table(title="Audio streams", border_style="bright_white", box=box.SQUARE_DOUBLE_HEAD)
    audio_table.add_column("No.")
    audio_table.add_column("Quality")
    audio_table.add_column("Filesize")
    audio_table.add_column("Bitrate")
    audio_table.add_column("Ext")
    audio_table.add_column("Codec")

    # Function to highlight resolution and display name in rich text format
    def res_highlight(resolution, display_name):
        text = Text()
        text.append(resolution, style="bright_cyan")
        text.append(" (")
        text.append(display_name, style="red1")
        text.append(")")
        return text

    def format_filesize(bytes):
        if not type(bytes) == int:  # Handle None or 0 value
            return "0.00 B"
        units = ["B", "KB", "MB", "GB", "TB"]
        i = 0
        while bytes >= 1024 and i < len(units):
            bytes /= 1024
            i += 1
        return f"{bytes:.2f} {units[i]}"

    for index, i in enumerate(video_formats):
        resolution = res_highlight(i.get("resolution", "None"), i.get("format_note", "None"))
        filesize = Text(format_filesize(i.get("filesize", 0)), style="dark_green")
        bitrate = Text(str(i.get("vbr", "None")), style="dodger_blue2")
        fps = Text(str(i.get("fps", "none")), style="bright_black")
        ext = Text(i.get("ext", "none"), style="bright_black")
        codec = Text(i.get("vcodec", "none"), style="bright_black")

        video_table.add_row(str(index+1), resolution, filesize, bitrate, fps, ext, codec)
    
    for index, i in enumerate(audio_formats):
        quality = Text(i.get("format_note", "None"), style="deep_pink2")
        filesize = Text(format_filesize(i.get("filesize", 0)), style="dark_green")
        bitrate = Text(str(i.get("abr", "None")), style="bright_blue")
        ext = Text(i.get("ext", "none"), style="bright_black")
        codec = Text(i.get("acodec", "none"), style="bright_black")

        audio_table.add_row(str(index+1), quality, filesize, bitrate, ext, codec)

    print("")

    console.print(video_table, audio_table)

    while True:
        print("")

        stream_number = input("Enter the stream number ('a' for audio, 'v' for video, e.g. 'v25'): ")

        if not len(stream_number) > 1:
            print("Please enter value.")
            exit()

        char = stream_number[0]

        if not(char == "a" or char == "v"):
            print("Please enter correct character.")
            exit()

        place_val = int(stream_number[1:])-1

        if stream_number.lower().startswith("a"):
            url = audio_formats[place_val]["url"]
            process = subprocess.Popen(['clip'], stdin=subprocess.PIPE, close_fds=True)
            process.communicate(input=url.encode('utf-8'))
        else:
            url = video_formats[place_val]["url"]
            process = subprocess.Popen(['clip'], stdin=subprocess.PIPE, close_fds=True)
            process.communicate(input=url.encode('utf-8'))

        print("Stream copied to clipboard!")