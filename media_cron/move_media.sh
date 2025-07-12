#!/bin/bash
tv_directory="/home/david/Documents/temp_media/tv"
movie_directory="/home/david/Documents/temp_media/movies"
port="3285"
ip="192.168.3.180"
directory=""

if [[ $# -ne 1 ]] || [[ "$1" -ne "movie" ]] || [[ "$1" -ne "tv" ]]; then
    echo "Usage move_media type"
    exit 1
fi

echo "Moving files to media server..."

if [[ "$1" == "movie" ]]; then
    directory="$movie_directory"
elif [[ "$1" == "tv" ]]; then
    directory="$tv_directory"
else
    echo "not a valid media type"
    exit 1
fi

if [ ! -d "$directory" ] || [ -z "$(ls "$directory")" ]; then
    echo "Error: could not find files"
    exit 1
fi

sftp -P "$port" blackbox@"$ip":/data <<EOF
    put "$directory"/*
    exit
EOF

if [[ $? -eq 0 ]]; then
    rm -rf "$directory"/*
    echo "command issued successfully"
    exit 0
else
    echo "error occured moving file: check sftp connection"
    exit 1
fi
