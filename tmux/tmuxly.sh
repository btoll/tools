#!/bin/bash
# TODO: allow choice of split.
# TODO: allow custom command to come from an env var?
# TODO: script assumes that the SDKs are names "SDK4", "SDK5", etc.
# TODO: it's probably best to specify the parent branch on the cli.

BRANCH=
BRANCH_EXISTS=
CREATE_BUG_DIR=true
FIDDLE=
HEAD=
NEW_BRANCH_FLAG=
# Note that creating a new bug ticket dir will also open the new test case in a browser, so by default we don't open it here.
OPEN_IN_BROWSER=false
RUN_COMMAND=
SDK=
SED_RANGE_BEGIN="<script type=\"text\/javascript\">"
TICKET=
TICKET_DIR_EXISTS=false
USE_BRANCH=true
VERSION=

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "bootstrap;get_fiddle;git-ls;make_file;tmux" -p "https://github.com/btoll/utils/blob/master/bootstrap.sh;https://github.com/btoll/utils/blob/master/get_fiddle.sh;https://github.com/btoll/utils/blob/master/git/bin/git-ls;https://github.com/btoll/utils/blob/master/make_file.sh;http://tmux.sourceforge.net"
fi

if [ $? -eq 0 ]; then
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

    # TODO: clean this up!
    branch_search() {
        cd /usr/local/www/SDK4
        BRANCH_EXISTS=$(git show-ref refs/heads/"$BRANCH")

        if [ -z "$BRANCH_EXISTS" ]; then
            cd /usr/local/www/SDK5
            BRANCH_EXISTS=$(git show-ref refs/heads/"$BRANCH")

            if [ -z "$BRANCH_EXISTS" ]; then
                checkout_parent_branch
                NEW_BRANCH_FLAG="-b"
            else
                VERSION=5
            fi
        else
            VERSION=4
        fi
    }

    checkout_parent_branch() {
        case "$VERSION" in
            6)
                SDK="SDK6"
                HEAD="sencha-6.0.x"
                ;;
            5)
                SDK="SDK5"
                HEAD="sencha-5.0.x"
                ;;
            *)
                SDK="SDK4"
                HEAD="extjs-4.2.x"
                ;;
        esac

        cd /usr/local/www/"$SDK"

        # When creating a new branch, it's extremely important to create off the "master" so we
        # MUST checkout that out before making the new topic branch.
        git checkout "$HEAD"
    }

    make_bug_dir() {
        cd "$BUGS"
        mkdir -m 0755 -p "$TICKET"
        cd "$TICKET"

        make_file -f "index.html" -v "$VERSION" -t "$TICKET" --fiddle "$FIDDLE"
        TICKET_DIR_EXISTS=true
    }

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
            --no-branch) USE_BRANCH=false ;;
            --no-bug-dir) CREATE_BUG_DIR=false ;;
            --ticket|-ticket|-t) shift; TICKET=$1 ;;
            --version|-version|-v) shift; VERSION=$1 ;;
        esac
        shift
    done

    if [ -z "$TICKET" ]; then
        echo "$(tput setaf 1)[ERROR]$(tput sgr0) No ticket specified."
        exit 1
    fi

    # If no version was specified, then we'll default to the latest version and start our search for topic branches there.
    if [ -z "$VERSION" ]; then
        VERSION=6
    fi

    SDK="SDK$VERSION"

    # We need to check right away if the ticket directory was already created b/c they will influence how we proceed.
    if [ -d "$BUGS/$TICKET" ]; then
        TICKET_DIR_EXISTS=true
        OPEN_IN_BROWSER=true
    elif [ -n "$FIDDLE" ] && "$CREATE_BUG_DIR"; then
        # If there isn't a bug directory, then we can go ahead and honor the fiddle config, if set. (Of course, it doesn't
        # make sense to download and process the fiddle if the bug directory isn't to be created.) If so, let's go through the
        # process of creating the bug dir, downloading the Fiddle preview, extracting our best-guess-attempt at the code body
        # (although it guesses very well) and finally slapping that into the new index.html.
        make_bug_dir
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
    BRANCH=${BRANCH:-"$TICKET"}

    tmux has-session -t $BRANCH 2>/dev/null
    if [ "$?" -eq 1 ]; then
        if "$USE_BRANCH"; then
            # Here we need to make sure we check out our "master" branch so we don't have a
            # topic branch as the parent of our new branch!
            checkout_parent_branch

            # Here we need to check if this branch already exists. If so, don't pass
            # the -b flag when the branch is checked out.
            #
            # We'll need to cd to the correct repo to check for existence.
            # Note that if the branch exists the return value will be in the form of
            # <SHA-1 ID> <space> <reference name> else it will be an empty string.
            cd /usr/local/www/"$SDK"
            BRANCH_EXISTS=$(git show-ref refs/heads/"$BRANCH")

            # If still no branch, then we know the following things:
            #   1. No version was specified when the command was run.
            #   2. The current value of SDK is the latest version, i.e., "SDK6".
            #   3. The topic branch doesn't "exist" in the local repo of the latest version.
            #   4. We need to now search for the branch in other local repos.
            if [ -z "$BRANCH_EXISTS" ]; then
                branch_search
            fi

            if [ -n "$NEW_BRANCH_FLAG" ]; then
                git checkout "$NEW_BRANCH_FLAG" "$BRANCH"
            else
                git checkout "$BRANCH"
            fi
        fi

        # If the bug ticket dir still doesn't exist when we reach here, create it if allowed.
        if [ "$TICKET_DIR_EXISTS" = "false" ] && "$CREATE_BUG_DIR"; then
            make_bug_dir
        fi

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

            if "$USE_BRANCH"; then
                RUN_COMMAND+=" -b $BRANCH"
            fi
        fi

        # Let's cd to our appropriate local repo before scripting tmux.
        cd /usr/local/www/"SDK$VERSION"

        tmux new-session -s $BRANCH -d
        tmux send-keys -t $BRANCH "$RUN_COMMAND" C-m

        # Finally, open a new pane for cli stuff (will already have been cd'd to the proper SDK).
        tmux split-window -h -p 45 -t $BRANCH
        tmux send-keys -t $BRANCH:0.1 'clear' C-m
    fi

    # Browse to the test case unless we're not creating a bug dir, then it doesn't make sense to.
    if "$OPEN_IN_BROWSER"; then
        open "http://localhost/extjs/bugs/$TICKET"
    fi

    tmux attach -t $BRANCH
fi

exit

