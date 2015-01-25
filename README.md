### Installation
To install the git scripts:

    1. Put the script anywhere in your PATH. For instance, `/usr/local/bin`.
    2. Make sure it's executable.
    3. Done.

----------------------------------------------------------------------------------------

### barchiver Python script
Must have at least Python 3.2

- Supports archive formats gzip, bzip2, tar and zip.
- Supports pushing archive to a remote server.
- Supports pointing script at a config file for the remote server params.

Example usage:

    barchiver --name my_archive_20131225 --src . --dest /usr/local/www/dotfiles
    barchiver --name motley --config ~/.barchiver/benjamintoll.com

For example, the file ~/.barchiver/benjamintoll.com in the example above could look like this:

    {
        "hostname": "benjamintoll.com",
        "username": "benjamin",
        "port": 2009,
        "format": "bztar"
    }

Usage:

    Optional flags:
    -h, --help    Help.
    -n, --name    An optional archive name. The default is YYYYMMDDHHMMSS.
    -s, --src     The location of the assets to archive. Defaults to cwd.
    -d, --dest    The location of where the assets should be archived. Defaults to cwd.
    -r, --root    The directory that will be the root directory of the archive. For example, we typically chdir into root_dir before creating the archive. Defaults to cwd.
    -c, --config  A config file that the script will read to get remote system information. Session will be non-interactive. Useful for automation.

### csv bash script
I had several csv files that I needed to slice by column(s). In addition, some lines had commas within double-quotes, which is no good when the field delimiter is the comma. So, I decided that this script will replace all commas not within double quotes to an underscore and then specify the underscore as the field delimiter in my import tool.

The command-line arguments are the csv to operate on, followed by an optional filename for the newly-created file (.csv will be appended) and the optional columns to slice.

If using a tool like mysqlimport, name the new file the same name as the database table that the records should be inserted into.

Example usage:

    bash csv.bash psa.csv cards 2-5


### bfind bash script

Example usage:

    bfind . Component.js
    bfind dir_name file_name

This does the following:

- finds every file that matches file_name in dir_name
- vim then opens each file in a vertically split pane

### bgrep bash script
Example usage:

    bgrep DEBUG[_]*SCRIPT .
    bgrep regex dir_name

This does the following:

- searches every file in dir_name
- pipes the results to cut which selects the first column of each line (delimited by a colon)
- pipes the result to uniq which filters out duplicates
- vim then opens each file in a vertically split pane
- the first file will be opened at the line where the regex is first found in the file

### brm bash script
Example usage:

    brm .DS_STORE __MACOSX
    brm file_or_dir_to_remove file_or_dir_to_remove

This does the following:

- searches every file in the cwd
- if more than one arg, it loops over the args and constructs the names to find
- recursively deletes everything that matches
- suppresses STDERR

### bsession bash script (for tmux and git)

Example usage:

    bsession -t 1972
    bsession --ticket 1992 -version 4
    bsession --ticket EXTJS-2009 --fiddle https://fiddle.sencha.com/#fiddle/da1
    bsession --ticket EXTJS-2009 --no-branch -f https://fiddle.sencha.com/#fiddle/da1
    bsession -ticket EXTJS-15678 --no-bug-dir
    bsession -ticket EXTJS-15678 --no-bug-dir --command "git ls -e t"

This does the following:

- Names the tmux session the same as the ticket number.
- cds to the appropriate SDK and creates the new topic branch.
- Splits the window to be 55% of the total width.
- Targets the new pane and creates the new ticket dir.
- Attaches to the tmux session.

In addition, it's possible to specify a Sencha Fiddle. In this case, it will download the Fiddle and use sed to extract the body of the `launch` command. This will then be inserted into the body of the onReady method in the `$BUGS/[new_ticket]/index.html` document.

If you do not wish to create a new ticket (and its directory),, set the `--no-bug-dir` flag.
If you do not wish to create a new topic branch, set the `--no-branch` flag.

Note that the `--no-bug-dir` flag trumps everything, including the presence of a Fiddle flag. In other words, a new ticket directory will never be created if that is set. However, it will still create a new topic branch (or checkout an existing one with the same name) as long as the `--no-branch` flag is not set.

If the `--no-bug-dir` flag is set, the bottom pane will open Vim and execute the editor command `:CtrlP` to start a file search with the CtrlP plugin.

Use cases:
- `bsession -t EXTJS-1972`
    This will create a new `EXTJS-1972` topic branch in the upper pane and a new bug directory called `EXTJS-1972` in the lower, opened to `index.html` in Vim.

- `bsession -t EXTJS-1972 --no-bug-dir`
    This will create a new `EXTJS-1972` topic branch in the upper pane and a file search in Vim in the lower (note there is a dependency on the CtrlP plugin).

- `bsession -t EXTJS-1972 --command "git ls -e t"
    This will create a new `EXTJS-1972` topic branch in the upper pane and run the command specified by the `--command` flag in the bottom pane.

- `bsession -t EXTJS-1972 --no-branch`
    This will not create a new topic branch but will `cd` to the appropriate SDK in the upper pane and a new bug directory called `EXTJS-1972` in the lower, opened to `index.html` in Vim.

Note that in all of the above cases it is possible to specify a Sencha Fiddle. This will download the Fiddle and make a best guess attempt to get the JavaScript within the `launch()` method, which will then be inserted into `index.html` in the new bug directory.

For more information, view help (`-help`, `-h`).

### bticket bash script (for ExtJS)
Example usage:
    `bticket 5671 3.4.0`

Example usage:
    `bticket EXTJSIV-11987 SDK4`

    bticket ticket_dir_name ext_version

Run the script wherever your ticket directories are located.

It will ask for the location of your SDK or build directory if the proper environment variables have not been set (`$EXT_SDK` and `$EXT_BUILDS`). If prompted for a location, hit enter to accept the default path (preset in the script).

This does the following:

- makes the directory in which the new ticket will live (in this example, `5671`).
- creates an `index.html` document within the new directory which properly references the JavaScript and CSS resources it needs to load.

The script properly handles versions 2.x, 3.x, 4.x, 5.x and any git repos that follow the naming convention of SDK*, i.e., SDK5.
