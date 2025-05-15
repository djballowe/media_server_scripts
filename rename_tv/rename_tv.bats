#!/usr/bin/env bats

SCRIPT="rename_tv.sh"
BATS_TEST_TMPDIR="$(pwd)"

setup() {
   TEST_DIR="$(mktemp -d "${BATS_TEST_TMPDIR}/test_rename_tv_XXXXXX")"

   echo "setup: ${TEST_DIR}"
   cd "$TEST_DIR"

   export MEDIA_BASE_PATH="$TEST_DIR/mnt/media/television"
}

teardown() {
   echo "teardown: ${TEST_DIR}"
   cd "$BATS_TEST_TMPDIR"
   rm -rf "$TEST_DIR"
   unset MEDIA_BASE_PATH
}

@test "script exits with error if improper usage" {
   run "$BATS_TEST_DIRNAME/$SCRIPT"
   expected="Usage: rename_tv title season episode_start folder_destination"

   [ "$status" -eq 1 ]

   if [ "$output" != "$expected" ]; then
      echo "recived: "$output""
      echo "expected: "$expected""
      return 1
   fi
}

@test "script detects .mkv files and files in folders" {
   # files
   touch This.Is.A.TV.show.S01E01.mkv
   touch this.is.a.tv.show.S01E02.mkv
   touch THIS.IS.A.TV.SHOW.S01E03.mkv
   touch this.is.a.virus.pretending.to.be.a.tv.show.S01E03.mkv.py
   touch this.is.not.a.tv.show.txt

   # folder only
   mkdir this.is.a.folder.mkv

   # folder with mkv inside
   mkdir this.show.folder
   touch this.show.folder/this.is.a.show.S01E04.mkv
   touch this.show.folder/this.is.not.a.show.nfo

   # create existing test media directory
   mkdir -p "$MEDIA_BASE_PATH/this/season_1"

   run "$BATS_TEST_DIRNAME/$SCRIPT" "This" "1" "1" "this"

   # exits without an error
   [ "$status" -eq 0 ] || {
      echo "output: $output"
   }

   # renamed files in new destination
   [ -f "$MEDIA_BASE_PATH/this/season_1/This.S01E01.mkv" ]
   [ -f "$MEDIA_BASE_PATH/this/season_1/This.S01E02.mkv" ]
   [ -f "$MEDIA_BASE_PATH/this/season_1/This.S01E03.mkv" ]
   [ -f "$MEDIA_BASE_PATH/this/season_1/This.S01E04.mkv" ]

   # original files should be moved
   [ ! -f "$TEST_DIR/This.Is.A.TV.show.S01E01.mkv" ]
   [ ! -f "$TEST_DIR/this.is.a.tv.show.S01E02.mkv" ]
   [ ! -f "$TEST_DIR/THIS.IS.A.TV.SHOW.S01E03.mkv" ]

   # non mkv files untouched
   [ -f "$TEST_DIR/this.is.a.virus.pretending.to.be.a.tv.show.S01E03.mkv.py" ]
   [ -f "$TEST_DIR/this.is.not.a.tv.show.txt" ]

   # any directories deleted
   [ ! -d "$TEST_DIR/this.is.a.folder.mkv" ]
   [ ! -d "$TEST_DIR/this.show.folder" ]
}
