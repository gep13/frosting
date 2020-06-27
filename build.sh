#!/usr/bin/env bash
# Define varibles
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_DIR/build.config
TOOLS_DIR=$SCRIPT_DIR/tools

if [ "$DOTNET_VERSION" = "" ]; then
    echo "An error occured while parsing .NET Core SDK version."
    exit 1
fi

# Make sure the tools folder exist.
if [ ! -d "$TOOLS_DIR" ]; then
  mkdir "$TOOLS_DIR"
fi

###########################################################################
# INSTALL .NET CORE CLI
###########################################################################

export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
export DOTNET_ROLL_FORWARD_ON_NO_CANDIDATE_FX=2

DOTNET_INSTALLED_VERSION=$(dotnet --version 2>&1)

if [ "$DOTNET_VERSION" != "$DOTNET_INSTALLED_VERSION" ]; then
    echo "Installing .NET CLI..."
    if [ ! -d "$SCRIPT_DIR/.dotnet" ]; then
      mkdir "$SCRIPT_DIR/.dotnet"
    fi
    curl -Lsfo "$SCRIPT_DIR/.dotnet/dotnet-install.sh" https://dot.net/v1/dotnet-install.sh
    bash "$SCRIPT_DIR/.dotnet/dotnet-install.sh" --version $DOTNET_VERSION --install-dir .dotnet --no-path
    export PATH="$SCRIPT_DIR/.dotnet":$PATH
    export DOTNET_ROOT="$SCRIPT_DIR/.dotnet"
fi

###########################################################################
# RUN BUILD SCRIPT
###########################################################################

echo "Running build script.."
pushd .
echo "Changing to build folder..."
cd build
echo "dotnet run..."
dotnet run --project Build.csproj -- "$@"
echo "going back to previous folder..."
popd
