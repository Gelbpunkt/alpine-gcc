#!/bin/sh
[ -d gcc-dir.tmp ] && echo gcc-dir.tmp already exists && exit 1
git clone --depth 1 git://gcc.gnu.org/git/gcc.git gcc-dir.tmp
git --git-dir=gcc-dir.tmp/.git fetch --depth 1 origin $1
git --git-dir=gcc-dir.tmp/.git archive --prefix=gcc-11.0.1/ $1 | xz -9e -T8 > gcc-11.0.1.tar.xz
rm -rf gcc-dir.tmp
