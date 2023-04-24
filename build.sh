#!/bin/bash
#
# A small script to automate the build of Signal packages for Android

set -euxo pipefail

# Check that we have some of the tools installed
which keytool
which apksigner
which docker

# Generate a key to sign APK packages with
if [ ! -f my-release-key.keystore ]; then
  keytool -genkey \
    -v \
    -storepass testtest \
    -keystore my-release-key.keystore \
    -alias testtest \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "cn=Test Test, ou=Test, o=Test, c=AU"
fi

# Grab the Signal source code / or update the local dir with the source code in it
git clone https://github.com/signalapp/Signal-Android ||
  (cd Signal-Android && git reset --hard && (git checkout main || true) && git pull)
cd Signal-Android

# Which versions of Signal to build APKs for:
# versions="v6.11.5 v6.18.0"
# or build most recent versions:
versions=$(git tag | sort -V | tail -n 30 | grep -v 'v.1.2.4' | grep -v 'v.4.50.1')

for SIGNAL_TAG in $versions; do

  # different versions need slightly different patches
  v=$(echo $SIGNAL_TAG | tr -d '.v')

  if [ "$v" -gt 6144 ]; then
    patch="patch-001-forced-upgrades-6.14.4.diff patch-002-enable-sms-6.15.3.diff"
  elif [ "$v" -gt 6139 ]; then
    patch="patch-001-forced-upgrades-6.14.4.diff patch-002-enable-sms-6.13.8.diff"
  elif [ "$v" -gt 6136 ]; then
    patch="patch-001-forced-upgrades-6.9.0.diff patch-002-enable-sms-6.13.8.diff"
  elif [ "$v" -gt 6110 ]; then
    patch="patch-001-forced-upgrades-6.9.0.diff patch-002-enable-sms-6.11.1.diff"
  elif [ "$v" -gt 689 ]; then
    patch="patch-001-forced-upgrades-6.9.0.diff patch-002-enable-sms-6.9.0.diff"
  elif [ "$v" -gt 680 ]; then
    patch="patch-001-forced-upgrades-6.8.1.diff patch-002-enable-sms-6.8.1.diff"
  else
    patch="patch-001-forced-upgrades-6.5.0.diff patch-002-enable-sms-6.5.0.diff"
  fi

  # skip previously built tags
  if [ -d ../${SIGNAL_TAG} ]; then
    echo "Skipping: ${SIGNAL_TAG}"

  else
    echo "Beginning: ${SIGNAL_TAG}"
    git reset --hard
    git checkout main
    git checkout ${SIGNAL_TAG}
    for p in $patch; do
      git apply ../$p
    done
    (cd reproducible-builds && docker build -t signal-android:${SIGNAL_TAG} .)
    docker run --rm -v $(pwd):/project -w /project signal-android:${SIGNAL_TAG} ./gradlew clean assemblePlayProdRelease

    mkdir -p ../${SIGNAL_TAG}
    find ./app/build/outputs/ -name "*.apk" -exec cp {} ../${SIGNAL_TAG}/ \;
    docker run --rm -v $(pwd):/project -w /project signal-android:${SIGNAL_TAG} rm -rf /project/app/build/outputs/ || true

    # Sign the apks (android won't let you install them otherwise)
    for i in ../${SIGNAL_TAG}/*.apk; do
      apksigner sign --ks ../my-release-key.keystore --ks-pass "pass:testtest" ${i}
    done
  fi

done
