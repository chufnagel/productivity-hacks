#/bin/bash
#-- Script to automate https://help.github.com/articles/why-is-git-always-asking-for-my-password
#-- Cribbed from https://gist.github.com/michaelsilver/6aa07e35a31f1f6b2e55
# Run this script while in a git directory to automatically convert origin (and upstream if you have it) from HTTP to SSH.
# If you have a million different git repos all in one directory, you can recursively run the script on all your clones like this:
# find /path/to/directory/with/many/git/repos -type d -exec sh -c 'cd "{}" ; /absolute/path/to/this/script.sh ;' \;


http_to_ssh(){
    echo ""
    echo "Checking for $1..."

    REPO_URL=`git remote -v | grep -m1 "^$1" | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`
    if [ -z "$REPO_URL" ]; then
	if [ "$1" == "upstream" ]; then
	    echo "-- No upstream found"
	    exit
	else
	    echo "-- ERROR:  Could not identify Repo url."
	    echo "   It is possible this repo is already using SSH instead of HTTPS."
	    exit
	fi
    fi

    USER=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\1#p'`
    if [ -z "$USER" ]; then
	echo "-- ERROR:  Could not identify User."
	exit
    fi

    REPO=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\2#p'`
    if [ -z "$REPO" ]; then
	echo "-- ERROR:  Could not identify Repo."
	exit
    fi

    NEW_URL="git@github.com:$USER/$REPO.git"
    echo "Changing repo url from "
    echo "  '$REPO_URL'"
    echo "      to "
    echo "  '$NEW_URL'"
    echo ""

    CHANGE_CMD="git remote set-url $1 $NEW_URL"
    echo "$CHANGE_CMD"
    `$CHANGE_CMD`
}

http_to_ssh "origin"
http_to_ssh "upstream"

echo "Success"