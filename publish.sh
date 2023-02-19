#!/bin/bash

set -euxo pipefail

test -v 1
test -d $1
test -v GITHUB_TOKEN

git tag ${1} || true
git push origin ${1}

release=$(curl -sSfL -X POST \
  -H "Accept: application/vnd.github+json"   \
  -H "Authorization: Bearer ${GITHUB_TOKEN}"  \
  -H "X-GitHub-Api-Version: 2022-11-28"   \
  https://api.github.com/repos/alexlance/signal-android-classic/releases   \
  -d '{"target_commitish":"main","name":"'${1}'","body":"APK packages for Signal '${1}'","draft":false,"prerelease":false,"generate_release_notes":false, "tag_name":"'${1}'"}')

#  "upload_url": "https://uploads.github.com/repos/alexlance/signal-android-classic/releases/92937818/assets{?name,label}",
url=$(echo "${release}" | jq -r .upload_url | cut -f1 -d'{')

cd ${1}
for n in *; do
  i=${n//unsigned-/}
  mv $n $i || true

  curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/octet-stream" \
    ${url}?name=$i \
    --data-binary "@${i}"

done
