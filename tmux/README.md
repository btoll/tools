### tmuxly bash script

Example usage:

    tmuxly -t 1972
    tmuxly --ticket 1992 -version 4
    tmuxly --ticket EXTJS-2009 --fiddle https://fiddle.sencha.com/#fiddle/da1
    tmuxly --ticket EXTJS-2009 --no-branch -f https://fiddle.sencha.com/#fiddle/da1
    tmuxly -ticket EXTJS-15678 --no-bug-dir
    tmuxly -ticket EXTJS-15678 --no-bug-dir --command "git ls -e t"

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

Use cases:
- `tmuxly -t EXTJS-1972`
    This will create a new `EXTJS-1972` topic branch in the upper pane and a new bug directory called `EXTJS-1972` in the lower, opened to `index.html` in Vim.

- `tmuxly -t EXTJS-1972 --no-bug-dir`
    This will create a new `EXTJS-1972` topic branch in the upper pane and a file search in Vim in the lower.

- `tmuxly -t EXTJS-1972 --command "git ls -e t"
    This will create a new `EXTJS-1972` topic branch in the upper pane and run the command specified by the `--command` flag in the bottom pane.

- `tmuxly -t EXTJS-1972 --no-branch`
    This will not create a new topic branch but will `cd` to the appropriate SDK in the upper pane and a new bug directory called `EXTJS-1972` in the lower, opened to `index.html` in Vim.

Note that in all of the above cases it is possible to specify a Sencha Fiddle. This will download the Fiddle and make a best guess attempt to get the JavaScript within the `launch()` method, which will then be inserted into `index.html` in the new bug directory.

For more information, view help (`--help`, `-help`, `-h`).

