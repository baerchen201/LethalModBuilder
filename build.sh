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

if [ -f prebuild.sh ]; then
  echo -e "\e[1;94m==== PRE-BUILD ====\e[0m"
  bash prebuild.sh
fi
echo -e "\e[1;94m====   BUILD   ====\e[0m"
dotnet build -c Release -o build
echo -e "\e[1;94m====    ZIP    ====\e[0m"
zip "release.zip" -jMM "manifest.json" build/**.dll
zip "release.zip" -j "icon.png" "README.md"
if [ -f postbuild.sh ]; then
  echo -e "\e[1;94m==== POST-BUILD ====\e[0m" # I hate this one character offset so much
  bash postbuild.sh
fi
echo -e "\e[1;94m====================\nRelease file created at \e[32m\"release.zip\"\e[0m"
