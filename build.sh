#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar

cd "$(dirname "$0")"
cd target

# Check for user build script (should create release.zip in working directory)
if [ -f build.sh ]; then
  exec bash build.sh
fi

# Default build script (fallback)

echo "Creating release directory..."
mkdir release # this directory shouldn't exist in the repo and shouldn't have any contents
if [ -f prebuild.sh ]; then
  echo -e "\e[1;94m==== PRE-BUILD ====\e[0m"
  bash prebuild.sh $1
fi
echo -e "\e[1;94m====   BUILD   ====\e[0m"
dotnet build -c Release -o build
echo -e "\e[1;94m====    ZIP    ====\e[0m"
zip "release.zip" -jMM "manifest.json" build/**.dll
set +e
zip "release.zip" -j "icon.png" "README.md"
_e="$?"
if [ "$_e" != 0 ] && [ "$_e" != 12 ]; then exit "$_e"; fi
unset _e
set -e
if [ -f postbuild.sh ]; then
  echo -e "\e[1;94m==== POST-BUILD ====\e[0m"
  bash postbuild.sh $1
fi
echo -e "\e[1;94m====  FINALIZE  ====\e[0m"
mv -v release.zip release
echo "Checking for nupkg files..."
shopt -s nullglob
if [ -n "$(echo build/*.nupkg)" ]; then
  cp -v build/*.nupkg release
else
  echo "No nupkg files"
fi
echo -e "\e[1;94m====================\nRelease files created at \e[32m\"target/release\"\e[0m"
