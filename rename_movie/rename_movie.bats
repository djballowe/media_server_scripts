SCRIPT="rename_movie.sh"
BATS_TEST_TMPDIR="$(pwd)"

setup() {
    TEST_DIR="$(mktemp -d "${BATS_TEST_TMPDIR}/test_rename_movie_XXXXXX")"

    echo "setup: ${TEST_DIR}"
    cd "$TEST_DIR"

    export MEDIA_BASE_PATH="$TEST_DIR/mnt/media/movies"
}

teardown() {
    echo "teardown: ${TEST_DIR}"
    cd "$BATS_TEST_TMPDIR"
    rm -rf "$TEST_DIR"
    unset MEDIA_BASE_PATH
}

@test "script exits with error if improper usage" {
    run "$BATS_TEST_DIRNAME/$SCRIPT"
    expected="Usage: rename_movie title year"

    [ "$status" -eq 1 ]

    if [ "$output" != "$expected" ]; then
        echo "recived: "$output""
        echo "expected: "$expected""
        return 1
    fi
}

@test "script detects .mkv files" {
    # files
    touch This.Is.A.movie.mkv
    touch this.is.a.virus.pretending.to.be.a.movie.mkv.py
    touch this.is.not.a.movie.txt

    # files from a different movie
    touch not.the.correct.movie.mkv

    mkdir -p "$MEDIA_BASE_PATH"

    run "$BATS_TEST_DIRNAME/$SCRIPT" "This" "1988"

    # exits without an error
    [ "$status" -eq 0 ] || {
        echo "output: $output"
        return 1
    }

    # renamed file in new destination
    [ -f "$MEDIA_BASE_PATH/This (1988).mkv" ]

    # original file should be moved
    [ ! -f "$TEST_DIR/This.Is.A.movie.mkv" ]

    # non mkv files untouched
    [ -f "$TEST_DIR/this.is.a.virus.pretending.to.be.a.movie.mkv.py" ]
    [ -f "$TEST_DIR/this.is.not.a.movie.txt" ]
}

@test "should match dots with spaces" {
    touch This.Is.A.movie.mkv

    mkdir -p "$MEDIA_BASE_PATH"

    run "$BATS_TEST_DIRNAME/$SCRIPT" "This is a movie" "2020"

    [ "$status" -eq 0 ] || {
        echo "output: $output"
        return 1
    }

    [ ! -f "$TEST_DIR/This.Is.A.movie.mkv" ]
    [ -f "$MEDIA_BASE_PATH/This is a movie (2020).mkv" ]
}

@test "should match spaces" {
    touch This\ Is\ A\ movie.mkv

    mkdir -p "$MEDIA_BASE_PATH"

    run "$BATS_TEST_DIRNAME/$SCRIPT" "This is a movie" "2020"

    [ "$status" -eq 0 ] || {
        echo "output: $output"
        return 1
    }

    [ ! -f "$TEST_DIR/This Is A movie.mkv" ]
    [ -f "$MEDIA_BASE_PATH/This is a movie (2020).mkv" ]
}
