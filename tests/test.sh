#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd );
function cleanTarget {
  rm -rf "$SCRIPT_DIR/target/"*;
  cp "$SCRIPT_DIR/dist-target-gitignore" "$SCRIPT_DIR/target/.gitignore";
}
function writeOutputToFile {
    echo $1 > "$SCRIPT_DIR/testOutput.log";
}
function errorExitMessage {
    echo $1;
    cleanTarget;
    echo "Failed flactomp3 automated tests. Aborting.";
    exit 1;
}
cleanTarget;
echo "Start flactomp3 automated tests.";
# Test a basic run with a 96k bitrate.
NORMAL=$(bash "$SCRIPT_DIR/../flactomp3.sh" --source source --target target --bitrate 96k);
NORMAL_TEST="failed";
while IFS= read -r LINE || [[ -n $LINE ]]; do
  if [[ $LINE == *"converted: 5;"* ]]; then
    echo "All flac files were converted. Normal test successful.";
    NORMAL_TEST="succeeded";
    break;
  fi
done < <(printf '%s' "$NORMAL");
if [[ "$NORMAL_TEST" == "failed" ]]; then
  writeOutputToFile "$NORMAL";
  errorExitMessage "Normal test failed. Check $SCRIPT_DIR/output.log for issues.";
fi
## Did copying the mp3 files work?
COPY_TEST="failed";
while IFS= read -r LINE || [[ -n $LINE ]]; do
  if [[ $LINE == *"copied: 2;"* ]]; then
    echo "All mp3 files were copied. Copy test successful.";
    COPY_TEST="succeeded";
    break;
  fi
done < <(printf '%s' "$NORMAL");
if [[ "$COPY_TEST" == "failed" ]]; then
  writeOutputToFile "$NORMAL";
  errorExitMessage "Copy test failed. Check $SCRIPT_DIR/output.log for issues.";
fi

# Test that skipping existing files works
SKIP=$(bash "$SCRIPT_DIR/../flactomp3.sh" --source source --target target --bitrate 96k);
SKIP_TEST="failed";
while IFS= read -r LINE || [[ -n $LINE ]]; do
  if [[ $LINE == *"processed: 7;"*"converted: 0;"* ]]; then
    echo "No flac files were converted. 7 files were processed. Skip test successful.";
    SKIP_TEST="succeeded";
    break;
  fi
done < <(printf '%s' "$SKIP");
if [[ "$SKIP_TEST" == "failed" ]]; then
  writeOutputToFile "$SKIP";
  errorExitMessage "Skip test failed. Check $SCRIPT_DIR/output.log for issues.";
fi

# Test a run with force conversion
FORCE=$(bash "$SCRIPT_DIR/../flactomp3.sh" --source source --target target --bitrate 96k --force-convert);
FORCE_TEST="failed";
while IFS= read -r LINE || [[ -n $LINE ]]; do
  if [[ $LINE == *"converted: 5;"* ]]; then
    echo "All flac files were converted. Force test successful.";
    FORCE_TEST="succeeded";
    break;
  fi
done < <(printf '%s' "$FORCE");
if [[ "$FORCE_TEST" == "failed" ]]; then
  writeOutputToFile "$FORCE";
  errorExitMessage "Force test failed. Check $SCRIPT_DIR/output.log for issues.";
fi

# Test that cleaning the target dir works
mv "$SCRIPT_DIR/source/testmp3a.mp3" "$SCRIPT_DIR/testmp3a.mp3";
CLEAN=$(bash "$SCRIPT_DIR/../flactomp3.sh" --source source --target target --bitrate 96k --clean-target);
CLEAN_TEST="failed";
while IFS= read -r LINE || [[ -n $LINE ]]; do
  if [[ $LINE == *"removed: 1"* ]]; then
    echo "The missing file was removed. Remove test successful.";
    CLEAN_TEST="succeeded";
    break;
  fi
done < <(printf '%s' "$CLEAN");
mv "$SCRIPT_DIR/testmp3a.mp3" "$SCRIPT_DIR/source/testmp3a.mp3";
if [[ "$CLEAN_TEST" == "failed" ]]; then
  writeOutputToFile "$CLEAN";
  errorExitMessage "Clean test failed. Check $SCRIPT_DIR/output.log for issues.";
fi

cleanTarget;
# End script
echo "End flactomp3 automated tests.";
exit 0;