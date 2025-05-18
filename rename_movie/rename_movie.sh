if [[ $# -ne 2 ]]; then
    echo "Usage: rename_movie title year"
    exit 1
fi

DIRECTORY="."
title=$1
year=$2

MEDIA_BASE_PATH="${MEDIA_BASE_PATH:-/mnt/media/movies}"
folder_path="${MEDIA_BASE_PATH}"

rename_file() {
    new_name=""$title" ("$year").mkv"
    full_path=""$folder_path"/"$new_name""

    sudo mv "$1" "$full_path"
    if [[ $? -ne 0 ]]; then
        echo "error occured moving file"
        exit 1
    fi
    echo "Moved file: "$1" to "$full_path""
}

for file in "$DIRECTORY"/*; do
    title_lower=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr -d '. ')
    basename=$(basename "$file")
    basename_lower=$(echo "$basename" | tr '[:upper:]' '[:lower:]' | tr -d '. ')

    if [[ -d "$file" && "$basename_lower" == *"$title_lower"* ]]; then
        echo "download is a dirctory attempting to extract .mkv"
        cd "$file"
        for inner_file in *; do
            if [[ -f "$inner_file" && "$inner_file" == *.mkv ]]; then
                echo "$inner_file has an mkv extention and is a file"
                rename_file "$inner_file"
            fi
        done
        cd ..
        rm -rf "$file"

    elif [[ -f "$file" && "$basename_lower" == *"$title_lower"* && "$file" == *.mkv ]]; then
        rename_file "$file"
    fi
done
