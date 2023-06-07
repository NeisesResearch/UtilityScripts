#!/bin/bash

# Define source and destination directories
SOURCE_DIR="attarch/"
DEST_DIR="test_bench/attarch/"

# Define directories or files to exclude
EXCLUDE=(
"am-cakeml" 
"linux-stable" 
"components/Measurement/configurations/linux_definitions.h" 
"components/Measurement/IntrospectionLibrary/IntrospectionLibrary.c"
)

# Build the exclude string
EXCLUDES=''
for exclude in "${EXCLUDE[@]}"; do
  EXCLUDES="$EXCLUDES --exclude $exclude"
done

# Run rsync command
eval "rsync -av --delete $EXCLUDES $SOURCE_DIR $DEST_DIR"

