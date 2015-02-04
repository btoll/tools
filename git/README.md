### git aliases

git get-hash

    git config --global alias.get-hash '!sh -c '"'git show \$0 | grep commit | cut -c8-'"

git goto

    git config --global alias.goto '!sh -c '"'git show \$0 | grep commit | cut -c8- | xargs git co'"

git hub

    git config --global alias.hub '!f()'" { Q=\$GIT_PREFIX; BR=\$(git rev-parse --abbrev-ref HEAD); if [[ \$# -eq 1 ]]; then Q+=\$1; fi; open https://github.com/extjs/SDK/blob/\$BR/\$Q; }; f"

git open

    git config --global alias.open '!f()'" { SHA=\$(git get-hash \$1); open https://github.com/extjs/SDK/commit/\$SHA; }; f"

git open-sha

    git config --global alias.open-sha '!sh -c '"'open https://github.com/extjs/SDK/commit/\$0'"

### git extensions

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

    -h  Help

    -f  It's possible to specify a file to which all of the git branch deletion commands will be written.
        This will not delete any branches. It's intention is to allow for further inspection of all the
        deletion candidates. The file will be executable.

    -l  Will operate in DRY RUN mode.  Will list all branches to be deleted.
        This is useful (and safe) when you are not sure which branches will be removed by the filter.

    --no-remote-delete Do not delete the branches remotely.

    -p  The pattern to use for existing local branches.
        Defaults to 'EXTJS.*'

    -r  The name of the remote repository from which to delete the branch.
        Defaults to 'origin'.

This does the following:

- warn you if you're in danger of deleting the remote HEAD. See the truth table below for how that could happen.
- will delete all branches that match the filter, both local and remote

Note that you can also define the following environment variables used by the script:

    GIT_DEFAULT_PATTERN
    GIT_DEFAULT_REPO

The biggest fear is of accidentally deleting a branch that hasn't been merged yet, and the most
likely scenario for this is that of an unpushed branch. To help ease that fear, the following
truth table shows the outcome of running the command for UNMERGED branches:
```
+-----------------------------------------------------------------------------------------------------+
|    Command          |  Is pushed  |  Has commits  |  On `foo`  |  Deleted Local  |  Deleted Remote  |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo         Y              Y                                                        |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo         Y              Y            Y                                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo         Y                           Y                                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo         Y                                           Y                 Y         |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo                        Y            Y                                           |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo                        Y                                                        |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo                                     Y                                           |
+-----------------------------------------------------------------------------------------------------+
|  git cleanup -p foo                                                     Y                           |
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

### git-get-hash

    !!! This is deprecated. Use the git alias instead. !!!

This will grep for the first commit hash in the branch or tag description. It can be useful in many different ways.

For example:
    - Use it to check out a tagged version.
    - Use it for the good or bad anchor when bisecting.
    - Use it in a pipeline.

When bisecting:

    git get-hash 4.2.2 | xargs git bisect good
    git bisect good $(git get-hash 4.2.2)
    git bisect bad `git get-hash 4.2.2`

This will grep for the first commit hash in the tag description and use it for the good or bad commit anchor for git-bisect.

When checking out a tagged version:

    git get-hash 5.2.2 | xargs git checkout
    git checkout $(git get-hash 4.2.2)
    git checkout `git get-hash 4.2.2`

When cherry picking:

    git cherry-pick $(git get-hash listfilter_prototype)

### git-goto

    !!! This is deprecated. Use the git alias instead. !!!

Example usages:

    git goto 5.1.0
    git goto extjs5.1.0

This is most useful when needing to quickly check out a release without having to know the tagged hash.

### git-hub

Open any file, directory or commit on GitHub in regular view or blame view.

It's best to show what this tool can do through examples.

- Open the current working directory:

    `git hub`

- Open the file:

    `git hub --file grid/filters/filter/List.js`

- Open the file in a blame view:

    `git hub -file grid/header/Container -blame`

- Open the file in a remote branch other than the default:

    `git hub -remote extjs-4.2.x -f Component.js`

- Don't open the file in a browser, dump it to STDOUT:

    `git hub -f Component.js --dry-run`

- Open the commit hash:

    `git hub -hash b51abf6f38902`

- Open the commit hash to which the local topic branch points:

    `git hub --branch EXTJS-15755`

- Open the commit hash to which the tag points:

    `git hub --tag extjs5.1.0`

The file will be opened in the remote branch whose value is in the `GITHUB_DEFAULT_REMOTE_BRANCH` environment variable unless changed using the `--remote` flag.

### git-introduced

Find the commit(s) that introduced or removed a method or other search pattern.

Example usages:

    git introduced --pattern onGridDestroy
    git introduced -p injectLockable --open-in-browser
    git introduced -pattern onDestroy -location ext/src/grid --no-delete-file
    git introduced -p getDragData -l dd | tee my_search_results

It is basically a wrapper for ```git log -S``` and returns the same results, however there are several advantages to it:

    - Opens all search results in its own tabbed browser window.
      This can be incredibly useful when discussing an issue with a colleague over the internets.
      Currently only supported on Mac OS X.

    - Ease of typing.
      Since it provides sensible defaults for the formatting, it's not necessary to lookup the tokens to
      provide your own. In addition, it will automatically use the current working directory as the search
      location (as the last argument after the ```--```) which can significantly speed up the query.

      The found matches will be in the following format (to STDOUT):

          Hash (short)    ->  6449ce9
          Author name     ->  Benjamin Toll
          Author email    ->  benjam72@yahoo.com
          Commit message  ->  Ensure column filter menu is destroyed when adding new column filters.
          Merge date      ->  Mon Nov 24 13:27:27 2014 -0500
          Url             ->  https://github.com/extjs/SDK/commit/6449ce9

    - Will keep the auto-generated CSV file on disk by passing the ```--no-delete-file``` flag.

### git-ls

List the files that are staged and modifed or that make up any given commit and optionally open in Vim for editing.

It's best to show what this tool can do through examples.

- List the files that make up the latest commit.

    `git ls`

- List the files that are in the staged area and are modified in the workspace.

    `git ls --dirty`

- Opens all listed files in Vim in vertically-split windows.

    `git ls --edit v`

- Opens all listed files in Vim in tabs for the specified hash (note that it will default to HEAD).

    `git ls --commit HEAD -e t`

- Opens all listed files in Vim (in buffers).

    `git ls -edit b`

- Opens all listed files for the specified hash (cf457b6) in horizontally-split windows.

    `git ls -c cf457b6 -e h`

- Opens all listed files for the specified hash (cf457b6) that match that specified regular expression in horizontally-split windows.

    `git ls -c cf457b6 -pattern debugger -e h`

### git-review

    !!! This is deprecated. Use git-ls instead. !!!

Example usages:

    git review
        - List the files that make up the latest commit.

    git review --edit v
        - Opens all listed files in Vim in vertically-split windows.

    git review -edit b -limit 4
        - Opens all listed files in Vim (in buffers), limiting the number of files opened to the first four.

    git review -e h -l 3
        - Opens all listed files in horizontally-split windows, limiting the number of files opened to the
          first three.

    git review -pattern debugger -e h -l 3
        - Opens all modified files that match that specified regular expression in horizontally-split windows,
          limiting the number of files opened to the first three.

