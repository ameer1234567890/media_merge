video_folder="video"
audio_folder="audio"
output_folder="output"
mkdir -p "$output_folder"

files="`ls \"$video_folder\"/*.{mp4,mpg,mpeg,MP4,MPG,MPEG} 2> /dev/null`"
if [ ! "$files" ]; then
  echo "No video files found! Exiting...."
  exit 1
fi

files_count="`echo \"$files\" | wc -l`"
i=0
while read -r file; do
  i="`expr $i + 1`"
  file="`echo \"$file\" | cut -d '/' -f 2`"
  echo -n "Processing file $i...."
  video_file="$file"
  audio_file="`echo \"$file\" | sed -e 's/MP4 [0-9]*p/MP4 Audio/g'`"
  if [ ! "$audio_folder/$audio_file" ]; then
    echo "Error: Audio file not found! Skipping file...."
  else
    echo "OK"
    echo -n "Merging file $i...."
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
    echo -n "Cleaning up source files...."
    rm "$video_folder/$video_file"
    rm "$audio_folder/$audio_file"
    echo "Done!"
    echo ""
  fi
done <<< "$files"
