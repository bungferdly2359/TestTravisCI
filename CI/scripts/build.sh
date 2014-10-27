#!/bin/sh

# The script exits immediately if any statement or command returns non-true value
set -e
set -o pipefail

HAVE_XCPRETTY="gem list xcpretty -i"
if ! $HAVE_XCPRETTY; then 
	gem install xcpretty
fi
	
DESTINATION="platform=iOS Simulator,name=iPhone 5"

echo ""
echo "************************************************************************"
echo "*                                Build                                 *"
echo "************************************************************************"
echo ""

xcodebuild -workspace "$PROJECT_NAME" -scheme "$SCHEME_NAME" -destination "$DESTINATION" build analyze | xcpretty -c

echo ""
echo "************************************************************************"
echo "*                            Run Unit Tests                            *"
echo "************************************************************************"
echo ""

xcodebuild -workspace "$PROJECT_NAME" -scheme "$SCHEME_NAME" -destination "$DESTINATION" test | xcpretty -c

