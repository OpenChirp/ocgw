#export CROSS_COMPILE="arm-linux-gnueabi-"
#export CFLAGS="-mfloat-abi=soft -O2 -Wall -Wextra -std=c99 -Iinc -I." 
_TeMp=$(readlink -f $BASH_SOURCE)
export GOPATH="$(dirname $_TeMp)/go"
export GOARCH=arm
export GOOS=linux
unset _TeMp
