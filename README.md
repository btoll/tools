### Setup aliases
For example:

    alias barchiver="python3 /usr/local/www/utils/barchiver.py"
    alias bfind="/usr/local/www/utils/bfind.sh"
    alias bgone="/usr/local/www/utils/bgone.sh"
    alias bgrep="/usr/local/www/utils/bgrep.sh"
    alias brm="/usr/local/www/utils/brm.sh"

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

### bgone git bash script

This script will delete any git branch, both locally and remotely, that has been merged and that
matches the filtered search.

If unsure about which branches your fuzzy search will match and delete, it is recommended to first
do a dry run using the `-l` switch.

This uses the git command `git branch --merged` under the covers.

Example usage:

    bgone [defaults to -r origin -f EXTJS*]
    bgone -r origin
    bgone -f HELLO*
    bgone -f WORLD* -r btoll

Usage:

    Optional flags:
    -f    The filter to use for existing local branches.
          Defaults to 'EXTJS*'

    -h    Help

    -l    Will operate in DRY RUN mode.  Will list all branches to be deleted.
          This is useful (and safe) when you are not sure which branches will be removed by the filter.

    -r    The name of the remote repository from which to delete the branch.
          Defaults to 'origin'

This does the following:

- will delete all branches that match the filter, both local and remote
- uses getopts, so will accept arguments in any order

Note that you can also define the following environment variables used by the script:

    GIT_DEFAULT_FILTER
    GIT_DEFAULT_REPO

The biggest fear is of accidentally deleting a branch that hasn't been merged yet, and the most
likely scenario for this is that of an unpushed branch. To help ease that fear, the following
truth table shows the outcome of running the command for UNMERGED branches:
```
+-----------------------------------------------------------------------------------------------+
|    Command    |  Is pushed  |  Has commits  |  On `foo`  |  Deleted Local  |  Deleted Remote  |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo         Y              Y                                                        |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo         Y              Y            Y                                 Y         |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo         Y                           Y                                 Y         |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo         Y                                           Y                 Y         |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo                        Y            Y                                           |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo                        Y                                                        |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo                                     Y                                           |
+-----------------------------------------------------------------------------------------------+
|  bgone -f foo                                                     Y                           |
+-----------------------------------------------------------------------------------------------+
```
For example, this first line can be read as:
'If I run the following command from a branch that is not `foo`, has one or more commits and has
been pushed to a remote repo, the branch will not be deleted either locally or remotely.'

The second line can be read as:
'If I run the following command from a branch that is `foo`, has one or more commits and has been
pushed to a remote repo, the branch will not be deleted locally but will be deleted remotely.'

The only scenarios in which a local branch will be deleted is when it contains no commits.

The script will not force delete (`-D`) any branches!

But as usual, make sure you know what you're doing! I am not responsible for lost branches!

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
