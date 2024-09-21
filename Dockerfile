# Use an official base image with necessary tools
FROM ubuntu:20.04

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa \
    sudo \
    && apt-get clean

# Set up Flutter SDK environment variables
ENV FLUTTER_HOME="/home/flutter/flutter-sdk"
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Clone the Flutter SDK from the official GitHub repository
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}

# Set proper permissions for the Flutter SDK
RUN chown -R root:root ${FLUTTER_HOME}

# Set Git's safe.directory configuration to avoid "dubious ownership" errors
RUN git config --global --add safe.directory ${FLUTTER_HOME}

# Pre-download Flutter dependencies and enable web & desktop support
RUN flutter precache && \
    flutter config --enable-web && \
    flutter config --enable-linux-desktop && \
    flutter config --enable-macos-desktop && \
    flutter config --enable-windows-desktop

# Accept Android licenses (optional if using Android builds)
RUN yes | flutter doctor --android-licenses || true

# Create a non-root user (and group) named flutteruser
RUN groupadd -r flutteruser && useradd -ms /bin/bash -g flutteruser flutteruser

# Switch to non-root user for further operations
USER flutteruser

# Set the working directory
WORKDIR /app

# Copy the pubspec files to cache dependencies
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build the Flutter app
RUN flutter build apk --release
