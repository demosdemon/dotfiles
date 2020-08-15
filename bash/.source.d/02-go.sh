#!/usr/bin/env bash

@setup-go() {
    local -r gp=/data/users/$USER/gopaths

    if [ -d "$gp" ]; then
        @prepend-path GOPATH "$gp/gofbcode"
        @prepend-path GOPATH "$gp/godeps"
        @prepend-path GOPATH "$gp/gobuck"
        @export GOROOT "$gp/goroot"
        @prepend-path PATH "$gp/go-tools/bin"
        @prepend-path PATH "$gp/goroot/bin"
    else
        @export GOPATH "$HOME/go"
        @export GO111MODULE on
    fi
}

@setup-go
unset -f @setup-go
