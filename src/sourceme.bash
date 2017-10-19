_TeMp=$(readlink -f $BASH_SOURCE)
export GOPATH="$(dirname $_TeMp)/go"
export GOARCH=arm
export GOOS=linux
unset _TeMp
