### Setup aliases
For example:

    alias bfind="/usr/local/www/utils/bfind.sh"
    alias bgrep="/usr/local/www/utils/bgrep.sh"

----------------------------------------------------------------------------------------

### bfind bash script
Example usage:
    `bfind . Component.js`

    bfind dir_name file_name

This does the following:

- finds every file that matches file_name in dir_name
- vim then opens each file in a vertically split pane


### bgrep bash script
Example usage:
    `bgrep DEBUG[_]*SCRIPT .`

    bgrep regex dir_name

This does the following:

- searches every file in dir_name
- pipes the results to cut which selects the first column of each line (delimited by a colon)
- pipes the result to uniq which filters out duplicates
- vim then opens each file in a vertically split pane
- the first file will be opened at the line where the regex is first found in the file
