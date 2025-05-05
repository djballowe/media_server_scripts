#!/usr/bin/env bash

DIRECTORY="."
title=$1
season=$2
episode=$3
folder=$4

if [[ $# -ne 4 ]]; then
        echo "Usage: "$0" title season episode_start folder_destination"
        exit 1
fi

folder_path="/mnt/media/television/"$folder"/season_"$season""
if [[ ! -d "$folder_path" ]]; then
        read -p "The folder destinaion does not exist. Would you like to create it? (y/n): " response
        if [[ "$response" == "y" ]]; then
                mkdir -p "$folder_path"
        else
                echo "exiting without moving files"
                exit 1
        fi
fi

for file in "$DIRECTORY"/*; do
        if [[ -f "$file" ]]; then
                base_name=$(basename "$file")
                episode_string="$episode"
                if [[ "$episode" -lt 10 ]]; then
                        episode_string="0"$episode""
                fi

                new_name=""$title".S"$season".E"$episode_string".mkv"
                full_path=""$folder_path"/"$new_name""

                sudo mv "$base_name" "$full_path"
                if [[ $? -ne 0 ]]; then
                        echo "error occured moving file"
                        exit 1
                echo "Moved file: "$base_name" to "$full_path""

                ((episode++))
        fi
done
