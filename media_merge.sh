#!/bin/sh
video_folder="video"
audio_folder="audio"
output_folder="output"

log_info(){
  printf "[\e[36m%s\e[0m] [\e[32mINFO\e[0m] $*" "$(date +'%H:%M:%S')"
}

log_warn(){
  printf "[\e[36m%s\e[0m] [\e[33mWARNING\e[0m] $*" "$(date +'%H:%M:%S')"
}

log_error(){
  printf "[\e[36m%s\e[0m] [\e[91mERROR\e[0m] $*" "$(date +'%H:%M:%S')"
}

{
  find $video_folder ! -name "$(printf "*\n*")" -name '*.MP4' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.mp4' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.MPG' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.mpg' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.MPEG' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.mpeg' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.AVI' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.avi' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.WMV' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.wmv' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.MOV' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.mov' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.3GP' 2> /dev/null
  find $video_folder ! -name "$(printf "*\n*")" -name '*.3gp' 2> /dev/null
} > tmp

mkdir -p "$output_folder"

files_count="$(< tmp wc -l 2> /dev/null)"
if [ "$files_count" -eq 0 ]; then
  log_error "No pictures found! Exiting....\n"
  exit 1
fi

count=0

while IFS= read -r file; do
  count="$((count + 1))"
  file="$(echo "$file" | cut -d '/' -f 2)"
  log_info "Processing file $count.... "
  video_file="$file"
  
  audio_file="$(echo "$video_file" | cut -d '/' -f 2)"
  audio_file="${audio_file%.*}"
  audio_exts="MP4 mp4 MPG mpg MPEG mpeg AVI avi WMV wmv MOV mov 3GP 3gp M4A m4a MP3 mp3 WMA wma AAC aac"
  for ext in $audio_exts; do
    if [ -f "$audio_folder/$audio_file.$ext" ]; then
      audio_file="$audio_file.$ext"
    fi
  done
  
  if [ "$audio_file" = "${audio_file%.*}" ]; then
    count="$((count - 1))"
    echo "Failed!"
    log_error "Error: Audio file not found! Skipping file....\n"
    echo ""
  else
    echo "OK"
    log_info "Merging file $count... "
    ffmpeg -hide_banner -loglevel panic -i "$video_folder/$video_file" -i "$audio_folder/$audio_file" -c copy "$output_folder/$video_file"

    ffmpeg_status="$?"
    if [ "$ffmpeg_status" != 0 ]; then
      count="$((count - 1))"
      echo "Failed!"
      log_error "ffmpeg Error: $ffmpeg_status. Skipping file....\n"
      echo ""
    elif [ ! -f "$output_folder/$video_file" ]; then
      count="$((count - 1))"
      echo "Failed!"
      log_error "Something went wrong! Output file not found! Skipping file....\n"
      echo ""
    else
      echo "Done!"
      log_info "Cleaning up source files.... "
      rm "$video_folder/$video_file"
      rm "$audio_folder/$audio_file"
      echo "Done!"
      echo ""
    fi
  fi
done < tmp
rm tmp

if [ "$count" -eq 1 ]; then
  log_info "$count file merged!\n"
else
  log_info "$count files merged!\n"
fi
