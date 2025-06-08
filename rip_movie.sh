#/usr/bin/env bash

DIRECTORY="/mnt/plex_media/movies"
movie_name=$1

if [[ ! -d "$DIRECTORY" ]]; then
    echo "plex media store not mounted to client PC"
    exit 1
fi

test_titles='TINFO:2,10,0,"5.5 GB"
TINFO:2,30,0,"Scott Pilgrim vs. the World - 15 chapter(s) , 5.5 GB"
TINFO:6,10,0,"2.2 GB"
TINFO:6,30,0,"Scott Pilgrim vs. the World - 25 chapter(s) , 2.2 GB"
TINFO:7,10,0,"1.1 GB"
TINFO:7,30,0,"Scott Pilgrim vs. the World - 7 chapter(s) , 1.1 GB"
TINFO:8,10,0,"1.1 GB"
TINFO:8,30,0,"Scott Pilgrim vs. the World - 4 chapter(s) , 1.1 GB"
TINFO:9,10,0,"1.0 GB"
TINFO:9,30,0,"Scott Pilgrim vs. the World - 8 chapter(s) , 1.0 GB"
TINFO:10,10,0,"4.3 GB"
TINFO:10,30,0,"Scott Pilgrim vs. the World - 17 chapter(s) , 4.3 GB"
TINFO:11,10,0,"1.7 GB"
TINFO:11,30,0,"Scott Pilgrim vs. the World - 10 chapter(s) , 1.7 GB"
TINFO:12,10,0,"10.4 GB"
TINFO:12,30,0,"Scott Pilgrim vs. the World - 38 chapter(s) , 10.4 GB"
TINFO:13,10,0,"6.1 GB"
TINFO:13,30,0,"Scott Pilgrim vs. the World - 2 chapter(s) , 6.1 GB"
TINFO:14,10,0,"3.4 GB"
TINFO:14,30,0,"Scott Pilgrim vs. the World - 21 chapter(s) , 3.4 GB"
TINFO:15,10,0,"47.2 GB"
TINFO:15,30,0,"Scott Pilgrim vs. the World - 20 chapter(s) , 47.2 GB"
TINFO:19,10,0,"47.2 GB"
TINFO:19,30,0,"Scott Pilgrim vs. the World , 47.2 GB"
TINFO:38,10,0,"1.8 GB"
TINFO:38,30,0,"Scott Pilgrim vs. the World , 1.8 GB"
TINFO:39,10,0,"1.3 GB"
TINFO:39,30,0,"Scott Pilgrim vs. the World , 1.3 GB"
TINFO:40,10,0,"1.6 GB"
TINFO:40,30,0,"Scott Pilgrim vs. the World , 1.6 GB"
TINFO:54,10,0,"1.5 GB"
TINFO:54,30,0,"Scott Pilgrim vs. the World , 1.5 GB"
TINFO:56,10,0,"2.0 GB"
TINFO:56,30,0,"Scott Pilgrim vs. the World , 2.0 GB"
TINFO:57,10,0,"1.1 GB"
TINFO:57,30,0,"Scott Pilgrim vs. the World , 1.1 GB"'

mkv_parse=$(makemkvcon -r info disc:0 | grep GB)
echo "Decrypting disc and assessing titles..."
# mkv_parse=$(echo "$test_titles" | grep GB)

title_size=$(echo "$mkv_parse" | cut -d',' -f1,4,5 | grep chapter | cut -d',' -f3 | tr -d " GB\"")
title_numbers=$(echo "$mkv_parse" | cut -d',' -f1,4,5 | grep chapter | cut -d',' -f1 | cut -d':' -f2 | tr '\n' ' ')

target_size_title=$(echo "$title_size" | awk 'NR==1{max=$0; max_index=NR} $0 > max {max=$0; max_index=NR} END{print max, max_index}')
index=$(echo "$target_size_title" | cut -d' ' -f2)
size=$(echo "$target_size_title" | cut -d' ' -f1)

echo "Largest title size is: "$size" GB"

read -ra sizes <<<"$title_numbers"
target_title=${sizes[$index - 1]}
echo "title number: "$target_title""

echo "$size"

echo "Attempting to rip title: "$target_title" - "$size" GB"
