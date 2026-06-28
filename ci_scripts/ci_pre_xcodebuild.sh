#!/bin/sh
# Xcode Cloud post-clone build hook. Runs before each Xcode Cloud build action.
# Stamps the build number from Xcode Cloud's monotonic CI_BUILD_NUMBER so every
# TestFlight/App Store upload has a unique, increasing build number.
#
# Xcode Cloud auto-discovers scripts named ci_post_clone.sh / ci_pre_xcodebuild.sh
# / ci_post_xcodebuild.sh in this ci_scripts/ directory at the repo root.
set -e

if [ -n "$CI_BUILD_NUMBER" ]; then
  echo "Setting CURRENT_PROJECT_VERSION to $CI_BUILD_NUMBER"
  # CI_PRIMARY_REPOSITORY_PATH is the checkout root inside Xcode Cloud.
  cd "$CI_PRIMARY_REPOSITORY_PATH"
  agvtool new-version -all "$CI_BUILD_NUMBER"
fi
