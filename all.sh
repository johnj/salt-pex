#!/usr/bin/env bash

set -e
set -x

dr=$(dirname "${0%/*}")
cd $dr

rm -rf build

# rhel based systems only for now
for dist in `echo centos`; do
  if [ $dist == "centos" ]; then
    versions="7"
  elif [ $dist == "ubuntu" ]; then
    versions="12.04 14.04 16.04 18.04"
  fi

  for distversion in $versions; do
    # remove old builds
    if [ -n "${PRUNE_DOCKER_AFTER_BUILD}" ]; then
      docker system prune -a -f
    fi

    rm -rf /var/tmp/saltbuild

    # weee
    docker run -v /var/tmp/:/var/tmp/ -v `pwd`:/app --entrypoint "/bin/bash" -it $dist:$distversion -x /app/build_salt_binaries.sh

    # copy artifacts
    mkdir -p build/${dist}${distversion}
    cp /var/tmp/saltbuild/* build/${dist}${distversion}/
  done
done
