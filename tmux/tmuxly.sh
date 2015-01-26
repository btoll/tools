#!/bin/bash
# TODO: allow choice of split.
# TODO: allow custom command to come from an env var?
# TODO: script assumes that the SDKs are names "SDK4", "SDK5", etc.

BASE_DIR=
BRANCH_EXISTS=
CREATE_BRANCH=true
CREATE_BUG_DIR=true
DEPENDENCIES=
DEPENDENCY=
FIDDLE=
FAILED_DEPENDENCIES=
PACKAGES=
RUN_COMMAND=
SDK=
SED_RANGE_BEGIN="<script type=\"text\/javascript\">"
SED_RANGE_END="<\/script>"
TESTCASE=
TICKET=
TICKET_DIR_EXISTS=false
TMP=
VERSION=5

# First, let's make sure that the system on which we are running has the dependencies installed.
DEPENDENCIES=(bticket git-ls gsed tmux)
PACKAGES=(
    "https://github.com/btoll/utils/blob/master/bticket.sh"
    "https://github.com/btoll/utils/blob/master/git/bin/git-ls"
    "To install on Mac, do 'brew install coreutils'"
    "http://tmux.sourceforge.net"
)

for n in ${!DEPENDENCIES[*]}; do
    DEPENDENCY=${DEPENDENCIES[n]}

    which $DEPENDENCY > /dev/null || {
        FAILED_DEPENDENCIES+="\n$DEPENDENCY\n${PACKAGES[n]}\n"
    }
done

if [ -n "$FAILED_DEPENDENCIES" ]; then
    echo "This script has several dependencies that are not present on your system."
    echo "Please install the following:"
    echo -e $FAILED_DEPENDENCIES
    exit 1
fi

# Next, let's make sure we have what we need.
usage() {
    echo "tmuxly"
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "--command, -command, -c : The command to run if a bug directory is not to be created. This will be run in the right pane."
    echo "                          Note that the presence of this flag trumps everything else."
    echo "                          Defaults to 'vim'."
    echo
    echo "--fiddle, -fiddle, -f   : Location of Fiddle to download using curl and paste into index.html in new bug dir."
    echo
    echo "--no-branch             : Don't create a new git topic branch (by default it will)."
    echo
    echo "--no-bug-dir            : Don't create a new bug directory (by default it will)."
    echo
    echo "--ticket, -ticket, -t   : The bug ticket number."
    echo
    echo "--version, -version, -v : The framework major version. Defaults to 5."
    echo
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Then, let's ask for the value of any environment vars that haven't already been set.
if [ -z "$BUGS" ]; then
    read -p 'Absolute path of bug directory (export a $BUGS environment variable to skip this check): ' BUGS
fi

# Swap out for user-provided options if given.
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        --help|-help|-h) usage; exit 0 ;;
        --command|-command|-c) shift; RUN_COMMAND=$1 ;;
        --fiddle|-fiddle|-f) shift; FIDDLE=$1 ;;
        --no-branch) CREATE_BRANCH=false ;;
        --no-bug-dir) CREATE_BUG_DIR=false ;;
        --ticket|-ticket|-t) shift; TICKET=$1 ;;
        --version|-version|-v) shift; VERSION=$1 ;;
    esac
    shift
done

if [ -z "$TICKET" ]; then
    echo "Error: No ticket specified."
    exit 1
fi

SDK=SDK$VERSION

# We need to check right away if the ticket directory was already created b/c they will influence how we proceed.
if [ -d "$BUGS$TICKET" ]; then
    TICKET_DIR_EXISTS=true
elif
    # If there isn't a bug directory, then we can go ahead and honor the fiddle config, if set. (Of course, it doesn't
    # make sense to download and process the fiddle if the bug directory isn't to be created.) If so, let's go through the
    # process of creating the bug dir, downloading the Fiddle preview, extracting our best-guess-attempt at the code body
    # (although it guesses very well) and finally slapping that into the new index.html.
    [ -n "$FIDDLE" ] && "$CREATE_BUG_DIR"; then

    # Let's re-use $FIDDLE.
    BASE_DIR=$(basename $FIDDLE)

    # Let's accept either a regular Fiddle URL or a Fiddle preview URL.
    if [ "$BASE_DIR" != "preview" ]; then
        # Rename in this form: https://fiddle.sencha.com/fiddle/da1/preview
        FIDDLE="https://fiddle.sencha.com/fiddle/$BASE_DIR/preview"
    fi

    # Then download and extract just what we need.
    #
    # Here we will extract every line after the launch method and before the closing <script> tag.
    # -n                            -> don't print
    # '/<script...>/, /<\/script>/  -> match range
    # {                             -> if in this range
    #     /<script...>/             -> and line matches /<script...>/
    #         {d;p;n};              -> do not print the first line (the match), print the next line and read next row
    #     /<\/script>/              -> if line matches "<\/script>"
    #         q;                    -> quit, we have done all printing
    #     p                         -> if we come to here, print the line
    # }
    #
    # http://stackoverflow.com/a/744093
    # There's probably a better way to do this than creating a temporary file.
    #
    # Let's first cd to a dir where we know we have write permissions.
    pushd $BUGS

    # Let's create a temp file and set the name as the Unix timestamp to avoid any name collisions.
    TMP=$(date +%s)
    curl $FIDDLE | gsed -n "/$SED_RANGE_BEGIN/,/$SED_RANGE_END/{/$SED_RANGE_BEGIN/{d;p;n};/$SED_RANGE_END/{q};p}" > $TMP

    bticket $TICKET $SDK
    cd $TICKET

    sed -i '' -e "/$SED_RANGE_BEGIN/ {
        r ../$TMP
    }" index.html

    rm ../$TMP
    popd

    TICKET_DIR_EXISTS=true
fi

###############################################################
# 1. Name the session the same as the ticket number.
# 2. cd to the appropriate SDK and create the new topic branch.
# 3. Split the window to be 55% of the total width.
# 4. Target the new pane and create the new ticket dir.
# 5. Attach to the session.
###############################################################
tmux has-session -t $TICKET 2>/dev/null

if [ $? -eq 1 ]; then
    TESTCASE="$BUGS$TICKET/index.html"

    tmux new-session -s $TICKET -d
    tmux send-keys -t $TICKET 'cd $'$SDK C-m

    if $CREATE_BRANCH; then
        # Here we need to check if this branch already exists. If so, don't pass
        # the -b flag when the branch is checked out.
        #
        # We'll need to cd to the correct repo to check for existence.
        # Note that if the branch exists the return value will be in the form of
        # <SHA-1 ID> <space> <reference name> else it will be an empty string.
        pushd /usr/local/www/$SDK
        BRANCH_EXISTS="$(git show-ref refs/heads/"$TICKET")"
        popd

        if [ -z "$BRANCH_EXISTS" ]; then
            NEW_BRANCH="-b"
        fi

        tmux send-keys -t $TICKET 'git checkout '$NEW_BRANCH' '$TICKET C-m
    fi

    # Unfortunately, we need to pause here or the pane created below will not have checked out
    # the appropriate git topic branch yet before the the $RUN_COMMAND is run (git ls -e t)
    # (not sure why).
    sleep 1

    tmux send-keys 'clear' C-m
    tmux split-window -h -p 55 -t $TICKET

    # If the bug ticket dir still doesn't exist when we reach here, create it if allowed.
    if [ "$TICKET_DIR_EXISTS" = "false" ] && "$CREATE_BUG_DIR"; then
        # Change to the bugs directory to create the bug ticket dir.
        tmux send-keys -t $TICKET:0.1 "cd $BUGS" C-m
        tmux send-keys -t $TICKET:0.1 "bticket $TICKET $SDK" C-m

        TICKET_DIR_EXISTS=true
    fi

    # In all cases, cd back to the SDK.
    tmux send-keys -t $TICKET:0.1 'cd $'$SDK C-m

    # We need to determine the command to run in our editor pane. A reasonable assumption is that if
    # a custom command was given that it should trump everything and we'll use that (we're assuming
    # that the user knows what they're doing).
    if [ -z "$RUN_COMMAND" ]; then
        # If no custom command, we only want to run either of the following commands if the bug ticket
        # dir exists. Note that if the ticket dir exists then the --no-bug-dir flag is ignored if set.
        if "$TICKET_DIR_EXISTS"; then
            # Given no custom command and no topic branch, let's default to opening the test case.
            if [ -z "$BRANCH_EXISTS" ]; then
                tmux send-keys -t $TICKET:0.1 "vim $TESTCASE" C-m
            else
                # Note that this command will serve a dual purpose.  If there had been a previous
                # commit, it will open all the files in tabs. If not, it will still open the editor.
                #
                # https://github.com/btoll/utils/blob/master/git/bin/git-ls
                tmux send-keys -t $TICKET:0.1 "git ls -e t" C-m

                # If it exists, let's open the test case and make it the first tab.
                if [ -f "$TESTCASE" ]; then
                    # Yes, that's two returns at the end of the first command.
                    tmux send-keys -t $TICKET:0.1 ":tabnew" C-m C-m
                    tmux send-keys -t $TICKET:0.1 ":e $TESTCASE" C-m
                    tmux send-keys -t $TICKET:0.1 ":tabm0" C-m
                fi
            fi
        fi
    else
        tmux send-keys -t $TICKET:0.1 "$RUN_COMMAND" C-m
    fi
fi

# Browse to the test case unless we're not creating a bug dir, then it doesn't make sense to.
if "$TICKET_DIR_EXISTS"; then
    open "http://localhost/extjs/bugs/$TICKET"
fi

tmux attach -t $TICKET

