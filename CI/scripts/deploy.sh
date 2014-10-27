#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
set -e
set -o pipefail

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment."
  exit 0
fi

if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Building on a branch other than master. No deployment."
  exit 0
fi

if [ "$TRAVIS_REPO_SLUG" != "$REPO_SLUG" ]; then
  echo "It's not the main repo. No deployment."
  exit 0
fi

if [ -z "$APP_MANAGER_API_TOKEN" ]; then
  echo "App Manager API token is missing. Abort deployment."
fi

echo ""
echo "************************************************************************"
echo "*                                Archive                               *"
echo "************************************************************************"
echo ""

xcodebuild -workspace "$PROJECT_NAME" -scheme "$SCHEME_NAME" -archivePath "$PRODUCT_NAME.xcarchive" archive | xcpretty -c

echo ""
echo "************************************************************************"
echo "*                      Export Archive to IPA File                      *"
echo "************************************************************************"
echo ""

xcodebuild -exportArchive -exportFormat IPA -archivePath "$PRODUCT_NAME.xcarchive" -exportPath "$PRODUCT_NAME.ipa" -exportProvisioningProfile "$PROFILE_NAME"

echo ""
echo "************************************************************************"
echo "*         Upload IPA File to 2359 Media Enterprise App Manager         *"
echo "************************************************************************"
echo ""

VERSION_NUMBER=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST_PATH"`
BUILD_NUMBER=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST_PATH"`
SHORT_COMMIT=`echo $TRAVIS_COMMIT | cut -c1-7`
VERSION="$VERSION_NUMBER ($BUILD_NUMBER) #$SHORT_COMMIT"

curl https://app.2359media.net/api/v1/apps/$APP_ID/versions \
  -F binary="@$PRODUCT_NAME.ipa" \
  -F api_token="$APP_MANAGER_API_TOKEN" \
  -F platform="iOS" \
  -F version_number="$VERSION"

echo "\n"
