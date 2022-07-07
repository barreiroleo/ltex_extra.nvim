for i in *.mkv; do ffmpeg -i "$i" -vcodec libx264 -an "${i%.*}.mp4"; done
