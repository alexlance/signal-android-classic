#!/bin/bash

set -euxo pipefail

versions="v6.5.0 v6.5.1 v6.5.2 v6.5.3 v6.5.4 v6.5.5 v6.5.6 v6.6.0 v6.6.1 v6.6.2 v6.6.3 v6.7.0 v6.7.1 v6.7.2 v6.7.3 v6.7.4 v6.7.5 v6.7.6 v6.8.0 v6.8.1 v6.8.2 v6.8.3 v6.9.0 v6.9.1 v6.9.2 v6.10.0 v6.10.1 v6.10.2 v6.10.3 v6.10.4 v6.10.5 v6.10.6 v6.10.7 v6.10.8 v6.10.9 v6.11.0 v6.11.1 v6.11.2 v6.11.3 v6.11.4 v6.11.5 v6.11.6 v6.11.7 v6.12.0 v6.12.1 v6.12.2 v6.12.3 v6.12.4"

# check that we have some of the tools installed
which keytool
which apksigner
which docker

if [ ! -f my-release-key.keystore ]; then
  keytool -genkey -v -storepass testtest -keystore my-release-key.keystore -alias testtest -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "cn=Test Test, ou=Test, o=Test, c=AU"
fi

git clone https://github.com/signalapp/Signal-Android || (cd Signal-Android && git reset --hard && (git checkout main || true) && git pull)
cd Signal-Android

if ! grep -q upstream .git/config; then
  cat << EOF >> .git/config
[remote "upstream"]
  url = https://github.com/signalapp/Signal-Android.git
  fetch = +refs/heads/*:refs/remotes/origin/*
EOF
fi

for SIGNAL_TAG in $versions; do

  if [ -d ../${SIGNAL_TAG} ]; then
    echo "Skipping: ${SIGNAL_TAG}"

  else
    echo "BEGINNING: ${SIGNAL_TAG}"
    git reset --hard
    git checkout main
    git checkout ${SIGNAL_TAG}
    git apply ../patch-001-forced-upgrades.diff
    (cd reproducible-builds && docker build -t signal-android:${SIGNAL_TAG} .)
    docker run --rm -v $(pwd):/project -w /project signal-android:${SIGNAL_TAG} ./gradlew clean assemblePlayProdRelease

    mkdir -p ../${SIGNAL_TAG}
    find ./app/build/outputs/ -name "*.apk" -exec cp {} ../${SIGNAL_TAG}/ \;
    docker run --rm -v $(pwd):/project -w /project signal-android:${SIGNAL_TAG} rm -rf /project/app/build/outputs/  || true

    # sign the apks (android won't let you install them otherwise)
    for i in ../${SIGNAL_TAG}/*.apk; do
      apksigner sign --ks ../my-release-key.keystore --ks-pass "pass:testtest" ${i}
    done
  fi

done
