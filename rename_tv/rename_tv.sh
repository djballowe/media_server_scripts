#/usr/bin/env bash

if [[ $# -ne 4 ]]; then
        echo "Usage: rename_tv title season episode_start folder_destination"
        exit 1
fi

DIRECTORY="."
title=$1
season=$2
episode=$3
folder=$4

MEDIA_BASE_PATH="${MEDIA_BASE_PATH:-/mnt/media/television}"
folder_path="${MEDIA_BASE_PATH}/${folder}/season_${season}"

# if [[ ! -d "$folder_path" ]]; then
#         read -p "The folder destinaion does not exist. Would you like to create it? (y/n): " response
#         if [[ "$response" == "y" ]]; then
#                 mkdir -p "$folder_path"
#         else
#                 echo "exiting without moving files"
#                 exit 1
#         fi
# fi

rename_file() {
        episode_string="$episode"
        if [[ "$episode" -lt 10 ]]; then
                episode_string="0"$episode""
        fi

        season_string="$season"
        if [[ "$season" -lt 10 ]]; then
                season_string="0"$season""
        fi

        new_name=""$title".S"$season_string"E"$episode_string".mkv"
        full_path=""$folder_path"/"$new_name""

        mv "$1" "$full_path"
        if [[ $? -ne 0 ]]; then
                echo "error occured moving file"
                exit 1
        fi
        echo "Moved file: "$1" to "$full_path""

        ((episode++))
}

for file in "$DIRECTORY"/*; do
        title_lower=$(echo "$title" | tr '[:upper:]' '[:lower:]')
        basename=$(basename "$file")
        basename_lower=$(echo "$basename" | tr '[:upper:]' '[:lower:]')

        if [[ -d "$file" && "$basename_lower" == *"$title_lower"* ]]; then
                echo "download is a dirctory attempting to extract .mkv"
                cd "$file"
                for inner_file in *; do
                        if [[ -f "$inner_file" && "$inner_file" == *.mkv ]]; then
                                echo "$inner_file has an mkv extention and is a file"
                                rename_file $(basename "$inner_file")
                        fi
                done
                cd ..
                rm -rf "$file"

        elif [[ -f "$file" && "$basename_lower" == *"$title_lower"* && "$file" == *.mkv ]]; then
                rename_file $(basename "$file")
        fi
done
