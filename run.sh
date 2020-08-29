#!/usr/bin/bash
./update-tar.sh master
podman build -t gcctest:latest .
podman run --rm -it --name gcc -d gcctest:latest
podman cp gcc:/root/packages/packager/ . --pause=false
mv packager repository
