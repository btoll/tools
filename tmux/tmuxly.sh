#!/bin/bash
# TODO: allow choice of split.
# TODO: allow custom command to come from an env var?
# TODO: script assumes that the SDKs are names "SDK4", "SDK5", etc.

BRANCH=
BRANCH_EXISTS=
CREATE_BRANCH=true
CREATE_BUG_DIR=true
FIDDLE=
HEAD=
NEW_BRANCH_FLAG=
RUN_COMMAND=
SDK=
SED_RANGE_BEGIN="<script type=\"text\/javascript\">"
TICKET=
TICKET_DIR_EXISTS=false
VERSION=5

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "bootstrap;fiddler;git-ls;gsed;make_file;make_ticket;tmux" -p "https://github.com/btoll/utils/blob/master/bootstrap.sh;https://github.com/btoll/utils/blob/master/fiddler.sh;https://github.com/btoll/utils/blob/master/git/bin/git-ls';\"To install on Mac, do 'brew install coreutils'\";https://github.com/btoll/utils/blob/master/make_file.sh;https://github.com/btoll/utils/blob/master/make_ticket.sh;http://tmux.sourceforge.net"
fi

# Next, let's make sure we have what we need.
usage() {
    echo "tmuxly"
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "--branch, -branch, -b   : If the new branch uses an existing ticket, specify the new branch name using this flag."
    echo '                          Note that this flag cannot be used alone, the $TICKET must always be specified.'
    echo
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
        --branch|-branch|-b) shift; BRANCH=$1 ;;
        --command|-command|-c) shift; RUN_COMMAND=$1 ;;
        --fiddle|-fiddle|-f) shift; FIDDLE=$1 ;;
        --help|-help|-h) usage; exit 0 ;;
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

    cd $BUGS
    make_ticket -f $TICKET -v $SDK
    cd $TICKET

    fiddler "$FIDDLE"

    TICKET_DIR_EXISTS=true
fi

###############################################################
# 1. Name the session the same as the branch.
# 2. cd to the appropriate SDK and create the new topic branch.
# 3. Split the window.
# 4. Target the new pane and bootstrap the ticket.
# 5. Attach to the session.
# 6. Open the ticket in a browser window.
###############################################################

# If given a branch name, then we assume that the ticket directory already exists and this
# is another topic branch to fix the same ticket, i.e., EXTJS-2009b, EXTJS-15329_4, etc.
# From this point forward, TICKET only refers to the actual Jira ticket number and BRANCH
# refers to the tmux session name and the new git topic branch that will be created.
BRANCH=${BRANCH:-$TICKET}

tmux has-session -t $BRANCH 2>/dev/null

if [ $? -eq 1 ]; then
    tmux new-session -s $BRANCH -d
    tmux send-keys -t $BRANCH 'cd $'$SDK C-m

    if $CREATE_BRANCH; then
        # Here we need to check if this branch already exists. If so, don't pass
        # the -b flag when the branch is checked out.
        #
        # We'll need to cd to the correct repo to check for existence.
        # Note that if the branch exists the return value will be in the form of
        # <SHA-1 ID> <space> <reference name> else it will be an empty string.
        pushd /usr/local/www/$SDK
        BRANCH_EXISTS="$(git show-ref refs/heads/"$BRANCH")"

        # We can't cd back to our calling directory yet b/c we need to make sure we check out
        # our "master" branch so we don't have a topic branch as the parent of our new branch!
        if [ -z "$BRANCH_EXISTS" ]; then
            NEW_BRANCH_FLAG="-b"

            # When creating a new branch, it's extremely important to create off the "master"!
            HEAD=$([ "$VERSION" -eq 5 ] && echo "sencha-5.0.x" || echo "extjs-4.2.x")
            git checkout "$HEAD"
        fi

        # Now it's safe to cd back to our calling directory.
        popd

        tmux send-keys -t $BRANCH 'git checkout '$NEW_BRANCH_FLAG' '$BRANCH C-m
    fi

    # If the bug ticket dir still doesn't exist when we reach here, create it if allowed.
    if [ "$TICKET_DIR_EXISTS" = "false" ] && "$CREATE_BUG_DIR"; then
        # Change to the bugs directory to create the bug ticket dir.
        tmux send-keys -t $BRANCH "cd $BUGS" C-m
        tmux send-keys -t $BRANCH "make_ticket $TICKET $SDK" C-m

        TICKET_DIR_EXISTS=true
    fi

    # In all cases, cd back to the SDK.
    tmux send-keys -t $BRANCH 'cd $'$SDK C-m

    # We need to determine the command to run in our editor pane. A reasonable assumption is that if
    # a custom command was given that it should trump everything and we'll use that (we're assuming
    # that the user knows what they're doing), else bootstrap the bug ticket.
    #
    # Note that if the ticket dir exists then the --no-bug-dir flag is ignored if set.
    if [ -z "$RUN_COMMAND" ] && "$TICKET_DIR_EXISTS"; then
        # `bootstrap` will work regardless if there's a branch (or not):
        #     1. If there's a topic branch, open the test case (if present) and the committed files.
        #     2. If no topic brach, open the test case (if present).
        #     3. Will default to opening vim with not files loaded.
        #
        # Note that we must specify the $TICKET and $BRANCH the arguments to `bootstrap` b/c we can't
        # assume that the branch name is the same as the ticket name!
        # https://github.com/btoll/utils/blob/master/bootstrap.sh
        RUN_COMMAND="bootstrap -t $TICKET"

        if "$CREATE_BRANCH"; then
            RUN_COMMAND+=" -b $BRANCH"
        fi
    fi

    tmux send-keys 'clear' C-m
    tmux send-keys -t $BRANCH "$RUN_COMMAND" C-m

    # Finally, open a new pane for cli stuff.
    tmux split-window -h -p 45 -t $BRANCH
fi

# Browse to the test case unless we're not creating a bug dir, then it doesn't make sense to.
if "$TICKET_DIR_EXISTS"; then
    open "http://localhost/extjs/bugs/$TICKET"
fi

tmux attach -t $BRANCH

