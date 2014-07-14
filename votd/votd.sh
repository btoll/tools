#!/bin/bash
# Download a Vim tip of the day from the internet!

FILE=votd.html

getTip ()
{
    # Let's download and save it so we can operate on it before mailing it.
    # As of 20140608, there were 1,611 tips on http://vim.wikia.com/wiki/Vim_Tips_Wiki
    # There isn't a web service, so let's cap the range there.
    TIP=$((( RANDOM % 1611 ) + 1 ))
    # The tips take the format of http://vim.wikia.com/wiki/VimTip538
    URL=http://vim.wikia.com/wiki/VimTip$TIP
    curl -o $FILE $URL
}

getTip

# Resend if it's not a helpful tip!
# http://unix.stackexchange.com/a/48536
# This tip was deleted from the original vim.org web site, probably because it was spam.
# Tip 1241 has been removed
if grep -q "It is hard to find helpful information if there are too many tips" $FILE; then
    getTip
fi

# Delete everything but the user-inputted tip. Yes, it's VERY specific to the HTML template.
sed -i -e '/<b>created<\/b>/,/NewPP limit report/!d' $FILE 2>/dev/null

# Wrap the HTML fragment and include a link to the tip.
echo '<html><body><p><a href='$URL'>View Tip '$TIP' on vim.wikia.com!</a></p><br />' > tmp

# We want to delete the last 2 lines of the file (i.e., "<!-- \n NEWPP limit report"). This is a PITA
# to do with just sed, so let's get some help from our friend tac.
tac $FILE | sed '1,2d' | tac >> tmp

echo '</body></html>' >> tmp
mv tmp $FILE

# Now that we have a safer download, let's email it!
php votd.php $FILE

rm $FILE
