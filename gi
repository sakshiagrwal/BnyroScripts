#!/bin/bash

gitclone() { # repo name
	git clone "git@github.com:$USER_NAME/$1.git"
}

gitmainbranch() {
	git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

gitbranch() {
	git rev-parse --symbolic-full-name --abbrev-ref HEAD
}

gitlastmsg() {
	git show -s --format=%s
}

gitinit() { # repo location, # initial commit message
	git init
	git branch -M main
	git add -A
	git commit -am "${2:-Initial Commit}"
	git remote add origin "git@github.com:$1"
	git push -u origin main
}

gitpush() { # commit message
	git add -A
	git commit -am "$1"
	git push --set-upstream origin "$(gitbranch)"
}

gitremote() { # remote url, branch
	REMOTE="$(echo $1 | rev | cut -d '/' -f 2 | rev)"
	git remote add "$REMOTE" "$1"
	git fetch "$REMOTE"
	git checkout "$REMOTE/$2"
}

gitrefresh() {
	git config pull.rebase true
	git pull
	git push
}

gitsquash() { # the branch or commit to reset to, the commit message
	git reset --soft "$1"
	git add -A
	git commit -am "$2"
}

gitappend() { # append changes to the last commit
	gitsquash HEAD~1 "$(gitlastmsg)"
}

gitreset() { # upstream to reset to
	REV=${1:-"upstream/master"}
	ORIGIN=$(echo "$REV" | cut -d '/' -f 1)
	git fetch "$ORIGIN"
	git reset --hard "$REV"
	git push
}

case ${1} in
clone) gitclone "$2" ;;
init) gitinit "$2" "$3" ;;
push) gitpush "$2" ;;
remote) gitremote "$2" "$3" ;;
refresh) gitrefresh ;;
squash) gitsquash "$2" "$3" ;;
append) gitappend ;;
reset) gitreset "$2" ;;
esac