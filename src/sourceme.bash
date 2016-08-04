_TeMp=$(readlink -f $BASH_SOURCE)
export GOPATH="$(dirname $_TeMp)/go"
unset _TeMp
