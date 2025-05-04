#!/usr/bin/env sh

if [ "$#" -ne 2 ]; then
        echo "Usage: $0 title year"
        exit 1
fi

title=$1
year=$2

ffmpeg -y -i ""$title".mkv" -dn -c:v copy -vbsf hevc_mp4toannexb -f hevc - | dovi_tool -m 2 convert --discard - -o ""$title".hevc"

MP4Box -add ""$title".hevc":dvp=8.1:xps_inband:hdr=none -brand mp42isom -ab dby1 -no-iod -enable 1 ""$title".mp4" -tmp "/mnt/media/dovi_converting/tmp_mp4"

ffmpeg -y -i ""$title".mp4" -i ""$title".mkv" -loglevel error -stats -map "0:v?" -map "1:a:1" -dn -map_chapters 0 -movflags +faststart -c:v copy -c:a copy -c:s mov_text -metadata title=""$title" ("$year")" -metadata:s:v:0 handler_name="HEVC HDR10 / Dolby Vision" -metadata:s:a:0 handler_name="EAC3 5.1 Dolby Atmos" -metadata:s:s:0 language=ell -metadata:s:s:0 handler_name="MPEG-4 Timed Text" -strict experimental ""$title"_dovi_profile8.mp4"
