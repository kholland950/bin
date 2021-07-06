#!/usr/bin/env bash

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

# Copy, linux and macos
if command_exists xclip > /dev/null 2>&1; then
    COPY='xclip -selection clipboard'
else
    COPY='pbcopy'
fi

LOCAL_DIR=~/.screenshots
mkdir $LOCAL_DIR > /dev/null 2>&1

if [ $# -eq 0 ]; then
	# most recent screenshot (macos only)
	SCREENSHOT=$(ls -t ~/Desktop/Screen\ Shot* | head -n 1)
	FN=$LOCAL_DIR/screenshot-$RANDOM.png
	cp "$SCREENSHOT" $FN
else
	# from file
	FN=$1
fi

BASENAME=$(basename $FN)

TARGET_HOST=aster.host
TARGET_USER=bskcx
TARGET_DIR=/srv/http/astro
TARGET_SCP_PORT=56123
BASE_URL=https://aster.host/astro/

scp -P $TARGET_SCP_PORT "$FN" $TARGET_USER@$TARGET_HOST:$TARGET_DIR > /dev/null 2>&1
URL=$BASE_URL$(urlencode "$BASENAME")
echo $URL | eval $COPY
echo $URL copied to clipboard

