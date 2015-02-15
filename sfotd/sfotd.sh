#!/bin/bash
# Download a shell-fu tip of the day from the internet!

FILE="sfotd.html"
# Let's use the timestamp for the name of the temp file to avoid any naming collisions.
TMP=$(date +%s)

# Let's download and save it so we can operate on it before mailing it.
# The tips take the format of http://vim.wikia.com/wiki/VimTip538
URL="http://www.shell-fu.org/lister.php?random"
curl -o $FILE $URL

# Since the beginning of the inner string we want is not at the beginning of the line, it's
# easier to first remove all end of line characters and then simply get the string of text
# we want from the single line.
cat "$FILE" | tr -d '\n' > /tmp/"$TMP"
# Note that the regex is surrounded by double quotes b/c we need to check for single quotes
# within the regex. Also, on Mac we need to pass empty string to -i flag so it doesn't create
# a backup.
sed -i '' -e "s/.*\(<div class=['\"]tipbody.*footwrap['\"]>\).*/\1/" /tmp/"$TMP"

# Overwrite the original download, we now need to wrap it with our HTML fragments.
echo "<html><body>" > "$FILE"
cat /tmp/"$TMP" >> "$FILE"
echo "</body></html>" >> "$FILE"

# Now that we have a safer download, let's email it!
php sfotd.php "$FILE"

rm /tmp/"$TMP"
