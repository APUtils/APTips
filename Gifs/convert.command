#!/bin/bash

set -e

base_dir=$(dirname "$0")
cd "$base_dir"

find . -name '*.mov' | xargs -I {} ffmpeg -i {} -an -s 480x852 -y -pix_fmt rgb24 -r 24 {}.gif
