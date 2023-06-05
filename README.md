# FLAC TO MP3
A simple little script to quickly convert FLAC files into MP3 files.

For when you need more space on your phone.

## Usage
The default settings will find any mp3 or flac files in the source directory. mp3 files will be copied to the target. flac files will be converted and saved in the target. The source directory structure will be preserved. Files that don't exist in the source, but do exist in the target will be ignored.
```bash
bash flactomp3.sh --source /path/to/source/root --target /path/to/target/root 
```
To force convert all flac files, even if they've been converted already:

```bash
bash flactomp3.sh --force-convert --source /path/to/source/root --target /path/to/target/root 
```
To remove files that don't exist in the source, but do exist in the target from the target:
```bash
bash flactomp3.sh --clean-target --source /path/to/source/root --target /path/to/target/root 
```

## Parameter
| Parameter       | required | default value                     | possible values                               | description                                                                                                                            |
|-----------------|----------|-----------------------------------|-----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| --help          | optional | on if present, off if not present | none                                          | Display help.                                                                                                                          |
| --source        | required | empty                             | Relative or absolute directory paths.         | The path to the source directory root.                                                                                                 |
| --target        | required | empty                             | Relative or absolute directory paths.         | The path to the target directory root.                                                                                                 |
| --config        | optional | '~/.config/flac2mp3'              | Relative or absolute directory paths.         | The path to the config directory root.                                                                                                 |
| --force-convert | optional | on if present, off if not present | none                                          | If set, any FLAC file found in the source will be converted. If the file already exists in the target, the target will be overwritten. |
| --clean-target  | optional | on if present, off if not present | none                                          | If set, any FLAC or MP3 file found in the target, but not found in the source, will be removed.                                        |
| --bitrate       | optional | 320k                              | Any value accepted by ffmpeg's `-b` parameter | Used to set the target audio bitrate of the mp3 file.                                                                                  |

## System Requirements
* Bash (tested on 5.1.4)
* ffmpeg (tested with 4.3.6)
* find (the command line tool)
* sed (the command line tool)

Developed on Debian 11. Any other Linux distribution should work just fine as long as they have the correct tools installed. 

## Support
Support is provided by the owner and the community on a best effort basis. 

All support/bug reports/feature request/pull requests should start as a discussion. The maintainers will move things to an issue if it is needed.

All questions are welcome. We only ask that you spend at least a little time searching for an answer on you own. Please include as much of what you have tried, and what you searched for, as you can.

## Code Of Conduct
If you can use a computer well enough to use a bash script, then you should be able to treat others properly. So our code of conduct is simple.

> **Treat others with respect and grace.**

### What that looks like:
* Never say "RTFM". Assume the user has, and just missed it. Give them a link to the appropriate section and ask if that helps. If they're still confused, help them. 
* Don't expect others to cater to your every demand.
* Assume the best interpretation of any given interaction.
* Do not insult or demean others.
* Do not seek to be offended by others.
* When in doubt, ask for clarification.

## Roadmap
[ ] Use `< config dir >/lastrun.timestamp` to only find new files.
[ ] Look into multithreading.

## Security
Please DO NOT report the security issue in the issue queue or discussions. Even if I take a bit to respond.

Email david@reagannetworks.com directly. I'll respond as soon as I'm able. If I don't respond within a day or two, start a discussion and ask me to check my spambox.

## Contributing
* Any code committed to this project belongs to this project as much as is legally possible. Basically, if this project is going to maintain the code, it needs to own the code.
* Follow the Code of Conduct.
* Please start a discussion before submitting a pull request.
* Anyone with a merged commit should be listed in [CONTRIBUTORS.md](CONTRIBUTORS.md).
* Make sure to update both [flactomp3.sh](flactomp3.sh) AND [flactomp3.template.sh](flactomp3.template.sh).
  * Use [argbash](https://argbash.dev/) to generate [flactomp3.sh](flactomp3.sh) from the changes you make to [flactomp3.template.sh](flactomp3.template.sh).
  * Copy the contents of [capture-exit-snippet.sh](capture-exit-snippet.sh) to the very start of the argbash generated code. See the current version of [flactomp3.sh](flactomp3.sh) for an example.
* Update [CONTRIBUTORS.md](CONTRIBUTORS.md) if you are not already in it.
* Code should be well commented.
* Code should not add more dependencies without really good reasons.
* Add appropriate tests to [tests/test.sh](tests/test.sh).

### Code Style
* Indent by 2 spaces.
* End statements with a semicolon.
* Non-argbash variables should be all caps.
* Start comments with at least two `#` and a space.

## Credit
The example flac files in [tests/source](tests/source) were copied from [flac-test-files](https://github.com/ietf-wg-cellar/flac-test-files/tree/main) and, I believe, are in the public domain.