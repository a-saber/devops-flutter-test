# Use the Flutter base image
FROM fischerscode/flutter:latest

# Set the working directory
WORKDIR /app

# Switch to root to create a non-root user
USER root

# Create a non-root user (and group) named flutteruser
RUN groupadd -r flutteruser && useradd -ms /bin/bash -g flutteruser flutteruser

# Set the Flutter SDK directory as safe for Git
RUN git config --global --add safe.directory /home/flutter/flutter-sdk

# Switch to non-root user to run the Flutter commands
USER flutteruser

# Copy the pubspec files to cache dependencies
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Set correct permissions for the android directory
USER root
RUN chown -R flutteruser:flutteruser /app/android

# Switch back to non-root user to run the build
USER flutteruser

# Build the Flutter app
RUN flutter build apk --release

