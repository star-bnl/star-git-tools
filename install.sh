#!/usr/bin/env bash

ORIG_PWD="$PWD"

make_install() {
    if [ -n "$PREFIX" ]
    then
        if [[ ! "$PREFIX" = /* ]]; then
            PREFIX="${ORIG_PWD}/${PREFIX}"
        fi
        PREFIX="$PREFIX" make install
    else
        make install
    fi
}

dir=$(mktemp -d -t star-git-tools-install.XXXXXXXXXX) \
    && cd "$dir" \
    && echo "Setting up 'star-git-install'..." \
    && git clone https://github.com/star-bnl/star-git-tools.git &> /dev/null \
    && cd star-git-tools \
    && make_install \
    && rm -rf "$dir"
