#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT_DIR/webash.sh"
TEMP_PATHS=()

cleanup() {
    local path

    for path in "${TEMP_PATHS[@]}"; do
        if [ -n "$path" ]; then
            rm -rf -- "$path"
        fi
    done
}

trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

new_temp_dir() {
    local dir

    dir=$(mktemp -d)
    TEMP_PATHS+=("$dir")
    printf '%s' "$dir"
}

track_temp_path() {
    TEMP_PATHS+=("$1")
}

assert_file() {
    [ -f "$1" ] || fail "Expected file: $1"
}

assert_dir() {
    [ -d "$1" ] || fail "Expected directory: $1"
}

assert_not_exists() {
    [ ! -e "$1" ] || fail "Expected path not to exist: $1"
}

assert_contains() {
    local file="$1"
    local expected="$2"

    grep -Fq "$expected" "$file" || fail "Expected '$file' to contain: $expected"
}

check_js_syntax() {
    if command -v node >/dev/null 2>&1; then
        node --check "$1" >/dev/null
    fi
}

test_bash_syntax() {
    bash -n "$SCRIPT"
}

test_direct_generation() {
    local tmp

    tmp=$(new_temp_dir)

    (
        cd "$tmp"
        printf 'n\n' | "$SCRIPT" >/dev/null
    )

    assert_file "$tmp/index.html"
    assert_file "$tmp/src/main.js"
    assert_file "$tmp/styles/style.css"
    assert_dir "$tmp/assets"
    assert_contains "$tmp/index.html" '<html lang="en">'
    check_js_syntax "$tmp/src/main.js"
}

test_subfolder_generation() {
    local tmp

    tmp=$(new_temp_dir)

    (
        cd "$tmp"
        printf 'y\ndemo_app\n' | "$SCRIPT" >/dev/null
    )

    assert_file "$tmp/demo_app/index.html"
    assert_file "$tmp/demo_app/src/main.js"
    assert_file "$tmp/demo_app/styles/style.css"
    assert_dir "$tmp/demo_app/assets"
    assert_contains "$tmp/demo_app/index.html" '<title>demo_app | Webash</title>'
    check_js_syntax "$tmp/demo_app/src/main.js"
}

test_conflict_rename_preserves_existing_directory() {
    local tmp

    tmp=$(new_temp_dir)
    mkdir "$tmp/existing"
    printf 'keep\n' > "$tmp/existing/marker.txt"

    (
        cd "$tmp"
        printf 'y\nexisting\nn\nnew_name\n' | "$SCRIPT" >/dev/null
    )

    assert_file "$tmp/existing/marker.txt"
    assert_file "$tmp/new_name/index.html"
}

test_invalid_subfolder_names_are_rejected() {
    local tmp
    local outside
    local outside_name

    tmp=$(new_temp_dir)
    outside=$(mktemp -u "${TMPDIR:-/tmp}/webash-outside.XXXXXX")
    outside_name=$(basename "$outside")
    track_temp_path "$outside"

    (
        cd "$tmp"
        printf 'y\n../%s\nbad/name\nbad name\nok-name\n' "$outside_name" | "$SCRIPT" >/dev/null
    )

    assert_not_exists "$outside"
    assert_file "$tmp/ok-name/index.html"
    assert_not_exists "$tmp/bad"
}

test_current_directory_name_is_escaped_in_generated_files() {
    local parent
    local unsafe_dir

    parent=$(new_temp_dir)
    unsafe_dir="$parent/bad'name <x>&\""
    mkdir "$unsafe_dir"

    (
        cd "$unsafe_dir"
        printf 'n\n' | "$SCRIPT" >/dev/null
    )

    assert_file "$unsafe_dir/index.html"
    assert_file "$unsafe_dir/src/main.js"
    assert_contains "$unsafe_dir/index.html" 'bad&#39;name &lt;x&gt;&amp;&quot;'
    check_js_syntax "$unsafe_dir/src/main.js"
}

test_bash_syntax
test_direct_generation
test_subfolder_generation
test_conflict_rename_preserves_existing_directory
test_invalid_subfolder_names_are_rejected
test_current_directory_name_is_escaped_in_generated_files

printf 'All tests passed.\n'
