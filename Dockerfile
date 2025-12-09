# 1. Use the specific, verified GHCR image as the base
FROM ghcr.io/cirruslabs/flutter:3.39.0-0.2.pre

# Set the working directory for your project source code
WORKDIR /app

# 2. Install any *additional* Linux system dependencies needed by your app's plugins.
# The base image handles the Android and Flutter SDKs, but not external libraries.
# Example if your app needs SQLite development files:
# RUN apt-get update && apt-get install -y libsqlite3-dev

# The entrypoint is already set up to use 'flutter' commands.
