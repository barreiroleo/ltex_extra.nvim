for i in *.mp4; do gifski --fps 5 -o "${i%.*}.gif" "$i" ; done
