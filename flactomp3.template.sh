#!/bin/bash
#
# FLAC TO MP3
# A simple little script to quickly convert FLAC files into MP3 files.
#
# For when you need more space on your phone.
#
# ARG_OPTIONAL_SINGLE([source], , [(required) The relative, or absolute directory path to the source directory root.])
# ARG_OPTIONAL_SINGLE([target], , [(required) The relative, or absolute directory path to the target directory root.])
# ARG_OPTIONAL_SINGLE([config], , [(optional) The relative, or absolute directory path to the config directory root.], [~/.config/flactomp3])
# ARG_OPTIONAL_BOOLEAN([force-convert], , [(optional) If set, any FLAC file found in the source will be converted. If the file already exists in the target, the target will be overwritten.], [off])
# ARG_OPTIONAL_BOOLEAN([clean-target], , [(optional) If set, any FLAC or MP3 file found in the target, but not found in the source, will be removed.],[off])
# ARG_OPTIONAL_SINGLE([bitrate], , [(optional) Any value accepted by ffmpeg's `-b` parameter, used to set the target audio bitrate of the mp3 file. ], [320k])
# ARG_HELP([A simple little script to quickly convert FLAC files into MP3 files. \n For when you need more space on your phone.])
# ARGBASH_GO

# [ <-- needed because of Argbash

START_TIMESTAMP=$(date +%s);
echo "Start flactomp3 conversion run at $(date)";


if [[ -z $_arg_source ]]; then
  echo "--source must have a value.";
  exit 1;
fi

if [[ -z $_arg_target ]]; then
  echo "--target must have a value.";
  exit 1;
fi

if [[ ! -d $_arg_source ]]; then
  echo "Please set --source to a valid directory.";
  exit 1;
fi

if [[ ! -d $_arg_target ]]; then
  echo "Please set --target to a valid directory.";
  exit 1;
fi

FIND=$(which find);
FFMPEG=$(which ffmpeg);

if [[ -z $FIND ]]; then
  echo "The linux command line tool 'find' must be present for flactomp3 to work. Please ensure that 'which' can find it. I.E. it needs to be in your PATH.";
  exit 1;
fi

if [[ -z $FFMPEG ]]; then
  echo "The linux command line tool 'ffmpeg' must be present for flactomp3 to work. Please ensure that 'which' can find it. I.E. it needs to be in your PATH.";
  exit 1;
fi

if [[ ! -d $_arg_config ]]; then
  mkdir -p "$_arg_config";
fi

if [[ -f "$_arg_config/lastrun.timestamp" ]]; then
  LAST_RUN=$(cat "$_arg_config/lastrun.timestamp");
else
  LAST_RUN=0;
fi

## Find all source files and store them in an array.
FIND_SOURCE_FILES=$($FIND $_arg_source -type f -regextype egrep -iregex '.*(\.mp3|\.flac)');
SOURCE_FILES_COUNT=0;
SOURCE_FILES=();
if [[ ! -z "$FIND_SOURCE_FILES" ]]; then
  while IFS= read -r FILE || [[ -n $FILE ]]; do
    SOURCE_FILES+=("$FILE");
    SOURCE_FILES_COUNT=$(($SOURCE_FILES_COUNT+1));
  done < <(printf '%s' "$FIND_SOURCE_FILES")
fi

## Find any existing target files and store them in an array.
FIND_TARGET_FILES=$($FIND $_arg_target -type f -regextype egrep -iregex '.*(\.mp3|\.flac)');
TARGET_FILES_COUNT=0;
TARGET_FILES=();
if [[ ! -z "$FIND_TARGET_FILES" ]]; then
  while IFS= read -r FILE || [[ -n $FILE ]]; do
    TARGET_FILES+=("$FILE");
    TARGET_FILES_COUNT=$(($TARGET_FILES_COUNT+1));
  done < <(printf '%s' "$FIND_TARGET_FILES")
fi

## Make sure to escape /'s in the paths for when we need to run replacements.
ESCAPED_SOURCE=$(echo $_arg_source | sed -r 's/\//\\\//g');
ESCAPED_TARGET=$(echo $_arg_target | sed -r 's/\//\\\//g');

PROCESSED_FILE_COUNT=0;
MP3_FILE_COUNT=0;
FLAC_FILE_COUNT=0;
CONVERTED_FILE_COUNT=0;
COPIED_FILE_COUNT=0;
for FILE in "${SOURCE_FILES[@]}"; do
    PROCESSED_FILE_COUNT=$(($PROCESSED_FILE_COUNT+1));
  echo "Processing source file #$PROCESSED_FILE_COUNT: $FILE";

  ## Assume we will convert.
  CONVERT=1;

  ## Assume we will not copy.
  COPY=0;

  if [[ ${FILE,,} == *".mp3" ]]; then
    MP3_FILE_COUNT=$(($MP3_FILE_COUNT+1));
    ## The source file is an .mp3 file. No need to convert,
    ## so just copy it.
    COPY=1;
    CONVERT=0;
  elif [[ ${FILE,,} == *".flac" ]]; then
    FLAC_FILE_COUNT=$(($FLAC_FILE_COUNT+1));
    ## The source file is an .flac file. Need to convert,
    COPY=0; # Just to make sure, for sure.
    CONVERT=1;
  fi

  ## What will the target file path be?
  REPLACE_SOURCE_WITH_TARGET=$(echo "$FILE" | sed -r s/$ESCAPED_SOURCE/$ESCAPED_TARGET/g);
  REPLACE_FLAC_WITH_MP3=$(echo "$REPLACE_SOURCE_WITH_TARGET" | sed -r s/\.flac/\.mp3/g);
  if [[ -f "$REPLACE_FLAC_WITH_MP3" ]]; then
    echo "Found existing file at $REPLACE_FLAC_WITH_MP3";
    if [[ "$_arg_force_convert" != "on" ]]; then
      ## Target file exists, and force-convert is off, so we
      ## will NOT convert
      CONVERT=0;
      ## Target file exists, and force-convert is off, so we
      ## will NOT copy
      COPY=0;
      echo "Force convert was off for $REPLACE_FLAC_WITH_MP3.";
    else
      CONVERT=1;
    fi
  fi

  ## Create the target directory if it doesn't already exist.
  if [[ $CONVERT == 1 || $COPY == 1 ]]; then
    TARGET_DIR_NAME=$(dirname "$REPLACE_FLAC_WITH_MP3");
    if [[ ! -d "$TARGET_DIR_NAME" ]]; then
      echo "$TARGET_DIR_NAME directory did not exist, creating it now.";
      mkdir -p "$TARGET_DIR_NAME";
    fi
  fi

  ## If $CONVERT is 1, run the conversion.
  if [[ $CONVERT == 1 ]]; then
    if [[ $FILE == *".mp3" ]]; then
      ## Never convert existing mp3 files, even if force convert is set.
      continue ;
    fi
    if [[ $_arg_force_convert == "on" && -f "$REPLACE_FLAC_WITH_MP3" ]]; then
      rm -f "$REPLACE_FLAC_WITH_MP3";
    fi
    echo "Converting to: $REPLACE_FLAC_WITH_MP3";
    $FFMPEG -loglevel fatal -i "$FILE" -ab "$_arg_bitrate" "$REPLACE_FLAC_WITH_MP3";
    CONVERTED_FILE_COUNT=$(($CONVERTED_FILE_COUNT+1));
  elif [[ $COPY == 1 ]]; then
    ## If $CONVERT is 0, and $COPY is 1, copy the file.
    echo "Copying to: $REPLACE_FLAC_WITH_MP3";
    cp "$FILE" "$REPLACE_FLAC_WITH_MP3";
    COPIED_FILE_COUNT=$(($COPIED_FILE_COUNT+1));
  else
    echo "Neither CONVERT nor COPY was 1, skipping file.";
  fi
done

## Remove target files that do not exist in source.
REMOVED_FILES_COUNT=0;
if [[ $_arg_clean_target == "on" ]]; then
  for TFILE in "${TARGET_FILES[@]}"; do
    ## What would the source file path be?
    REPLACE_TARGET_WITH_SOURCE=$(echo "$TFILE" | sed -r s/$ESCAPED_TARGET/$ESCAPED_SOURCE/g);
    REPLACE_MP3_WITH_FLAC=$(echo "$REPLACE_TARGET_WITH_SOURCE" | sed -r s/\.mp3/\.flac/g);
    if [[ -f "$REPLACE_TARGET_WITH_SOURCE" ]]; then
      continue ;
    elif [[ -f "$REPLACE_MP3_WITH_FLAC" ]]; then
      continue ;
    else
      echo "Did not find existing source file for $TFILE. File will be removed.";
      rm -f "$TFILE";
      REMOVED_FILES_COUNT=$(($REMOVED_FILES_COUNT+1));
    fi
  done
fi

END_TIMESTAMP=$(date +%s);
echo $END_TIMESTAMP > "$_arg_config/lastrun.timestamp";
echo "flactomp3 file counts - source: $SOURCE_FILES_COUNT; target: $TARGET_FILES_COUNT; processed: $PROCESSED_FILE_COUNT; source mp3: $MP3_FILE_COUNT; source flac: $FLAC_FILE_COUNT; converted: $CONVERTED_FILE_COUNT; copied: $COPIED_FILE_COUNT; removed: $REMOVED_FILES_COUNT.";
echo "Finished flactomp3 conversion run at: $(date)";
DIFF=$(($END_TIMESTAMP-$START_TIMESTAMP));
echo "flactomp3 conversion run took $DIFF seconds.";
exit 0;
# ] <-- needed because of Argbash