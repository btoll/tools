#!/bin/bash
# I had several csv files that I needed to slice by column(s). Also, I needed to replace any commas that weren't field delimiters.
# http://www.unix.com/302335072-post6.html
# http://blog.ijun.org/2008/12/vi-vim-remove-replace-comma-commas.html
# http://chriseiffel.com/everything-linux/how-to-import-a-large-csv-file-to-mysql/
# http://stackoverflow.com/a/11287641 to fix the following error:
#   sed: RE error: illegal byte sequence
#
if [ $# -eq 0 ]; then
    echo "Usage: $0 FILE_TO_OPERATE_ON {NEW_FILENAME} {COLUMN(S)_TO_CUT}"
    exit 1
fi

# If there's a second argument it should be the name of the new file, if not default to all.
FILENAME=${2-"new"}
# If there's a third argument it should be the columns to select, if not default to all.
COLUMNS=${3-"1-"}

# Make a backup of the file we're operating on.
cp $1 $1.bk

# Change any commas within quotes to tildes. We're editing in-place here.
# ***NOTE that GNU sed doesn't need the argument for -i!! (This was created on OSX.)***
# Here lies a brief explanation of what is happening. There are three commands that sed is executing:
# 1. Change all commas on a line to the new delimiter.
# 2. Establish a label that will be used to iterate in the next command until all replacements have been made.
# 3. Recurse within any double-quoted strings changing the given delimiter back to a comma.
# 4. The backreferences:
#   \1 Match starting in a double-quote until it meets an underscore (_).
#       \("[^"]*\)_
#
#   \2 Match anything starting from after an underscore until the closing double-quote.
#       _\([^"][^"]*"\)
#
#       Note that [^"][^"] will match chars that like `"$3,000","$4,000"`, i.e., two separate and distinct fields
#       that contain commas within the double-quotes.  With only one matcher `[^"]`, it will treat it as one field.
#
LANG=C sed -i '' -e 's/,/_/g' -e ':boom' -e 's/\("[^"]*\)_\([^"][^"]*"\)/\1,\2/; t boom' $1

# Create a new file of the columns specified in the 2nd command-line arg. Note the new delimiter.
LANG=C cut -d_ -f$COLUMNS $1 > $FILENAME.csv

# Remove our backup.
mv $1.bk $1

echo "Done. Created new file $FILENAME.csv"
exit 0
