#!/bin/sh
video_folder="video"
audio_folder="audio"
output_folder="output"
mkdir -p "$output_folder"

file_exts="mp4 mpg mpeg MP4 MPG MPEG"
for ext in $file_exts; do
  files="$files $(ls $video_folder/*."$ext" 2> /dev/null)"
done
if [ ! "$files" ]; then
  echo "No video files found! Exiting...."
  exit 1
fi

i=0
while read -r file; do
  i="$((i + 1))"
  file="$(echo "$file" | cut -d '/' -f 2)"
  printf "Processing file %s...." "$i"
  video_file="$file"
  audio_file="$(echo "$file" | sed -e 's/MP4 [0-9]*p/MP4 Audio/g')"
  if [ ! -f "$audio_folder/$audio_file" ]; then
    echo "Error: Audio file not found! Skipping file...."
  else
    echo "OK"
    printf "Merging file %s..." "$i"
    ffmpeg -hide_banner -loglevel panic -i "$video_folder/$video_file" -i "$audio_folder/$audio_file" -c copy "$output_folder/$video_file"

    ffmpeg_status="$?"
    if [ "$ffmpeg_status" != 0 ]; then
      echo "Failed!"
      echo "ffmpeg Error: $ffmpeg_status. Skipping...."
    fi

    if [ ! -f "$output_folder/$video_file" ]; then
      echo "Failed!"
      echo "Something went wrong! Output file not found! Skipping...."
    fi

    echo "Done!"
    printf "Cleaning up source files...."
    rm "$video_folder/$video_file"
    rm "$audio_folder/$audio_file"
    echo "Done!"
    echo ""
  fi
done <<< "$files"
