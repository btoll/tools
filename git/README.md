    To install the git scripts:

        1. Put the script anywhere in your PATH. For instance, `/usr/local/bin`.
        2. Make sure it's executable.
        3. Done.

    To install the git man pages:

        1. Put the file anywhere in your manpath. For instance, `/usr/local/share/man/man1`.
        2. Done.

### git-cleanup

This script will delete any git branch, both locally and remotely, that has been merged and that
matches the filtered search.

If unsure about which branches your fuzzy search will match and delete, it is recommended to first
do a dry run using the `-l` switch.

This uses the git command `git branch --merged` under the covers.

Example usage:

    git cleanup [defaults to -r origin -f EXTJS*]
    git cleanup -r origin
    git cleanup -f HELLO*
    git cleanup -f WORLD* -r btoll

Usage:

    Optional flags:
    -f    The filter to use for existing local branches. Accepts regular expressions.
          Defaults to 'EXTJS*'

    -h    Help

    -l    Will operate in DRY RUN mode.  Will list all branches to be deleted.
          This is useful (and safe) when you are not sure which branches will be removed by the filter.

    -r    The name of the remote repository from which to delete the branch.
          Defaults to 'origin'

This does the following:

- warn you if you're in danger of deleting the remote HEAD. See the truth table below for how that could happen.
- will delete all branches that match the filter, both local and remote

Note that you can also define the following environment variables used by the script:

    GIT_DEFAULT_FILTER
    GIT_DEFAULT_REPO

The biggest fear is of accidentally deleting a branch that hasn't been merged yet, and the most
likely scenario for this is that of an unpushed branch. To help ease that fear, the following
truth table shows the outcome of running the command for UNMERGED branches:
```
+-----------------------------------------------------------------------------------------------------+
|    Command          |  Is pushed  |  Has commits  |  On `foo`  |  Deleted Local  |  Deleted Remote  |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo         Y              Y                                                        |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo         Y              Y            Y                                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo         Y                           Y                                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo         Y                                           Y                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo                        Y            Y                                           |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo                        Y                                                        |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo                                     Y                                           |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -f foo                                                     Y                           |
+-----------------------------------------------------------------------------------------------------+
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

### git-hashtag
Example usages:

When bisecting:

    git hashtag 4.2.2 | xargs git bisect good
    git bisect good $(git hashtag 4.2.2)
    git bisect bad `git hashtag 4.2.2`

This will grep for the first commit hash in the tag description and use it for the good or bad commit anchor for git-bisect.

When checking out a tagged version:

    git hashtag 4.2.2 | xargs git checkout
    git checkout $(git hashtag 4.2.2)
    git checkout `git hashtag 4.2.2`

Note that you can pass just the version number or the full tag name.

### git-ls
Example usages:

    git ls
        - List the files that make up the latest commit.

    git ls --edit v
        - Opens all listed files in Vim in vertically-split windows.

    git ls -edit b -limit 4
        - Opens all listed files in Vim (in buffers), limiting the number of files opened to the first four.

    git ls -c cf457b6 -e h -l 3
        - Opens all listed files for the specified hash (cf457b6) in horizontally-split windows, limiting the
          number of files opened to the first three.

