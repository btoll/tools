### Setup aliases
For example:

    alias bgrep="/usr/local/www/utils/bgrep.sh"

----------------------------------------------------------------------------------------

### bgrep bash script
Example usage:
    `bgrep [Ww]arning .`

    bgrep regex dir_name

This does the following:

- searches every file in dir_name
- pipes the results to cut which selects the first column of each line (delimited by a colon)
- pipes the result to uniq which filters out duplicates
- vim then opens each file in a vertically split pane
- the first file will be opened at the line where the regex is first found in the file

