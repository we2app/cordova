# =========================================================================
# === Base Image Setup (from Dockerfile_base)
# =========================================================================
FROM ubuntu:24.04

# Combined labels, prioritizing the most specific (Cordova)
LABEL maintainer="atik@we2app.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Combined Cordova, Android, & JDK Image" \
      org.label-schema.description="Image with Cordova 12, Android SDK 35.0.0, and OpenJDK 17 on Ubuntu 24.04"

# Set non-interactive frontend to prevent prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# =========================================================================
# === Environment Variables
# =========================================================================
# Set JAVA_HOME (from Dockerfile_jdk)
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Set Android, Maven, Gradle, and Ant variables (from Dockerfile_android)
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip" \
    ANDROID_BUILD_TOOLS_VERSION=35.0.0 \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_SDK_ROOT="/opt/android" \
    ANDROID_HOME="/opt/android"

# Set Cordova variables (from Dockerfile_cordova)
ENV CORDOVA_VERSION=12.0.0 \
    CORDOVA_BUILD_TOOLS_VERSION=35.0.0

# Set NVM environment variables
ENV NVM_DIR="/root/.nvm"
ENV NVM_SYMLINK_CURRENT=true

# Update PATH to include all tool binaries, including the nvm symlink for Node.js
ENV PATH $PATH:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:$NVM_DIR/current/bin

# =========================================================================
# === System Dependencies & JDK Installation
# =========================================================================
# Update, upgrade, and install all required packages in a single layer
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install \
    openjdk-17-jdk-headless \
    wget \
    curl \
    maven \
    ant \
    gradle \
    gnupg2 \
    lsb-release \
    unzip \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =========================================================================
# === Android SDK Installation (from Dockerfile_android)
# =========================================================================
WORKDIR /opt

# Download and set up the Android SDK command-line tools
RUN mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    cd cmdline-tools && \
    mkdir latest && \
    ls | grep -v latest | xargs mv -t latest

# Accept SDK licenses and install Android components
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platforms;android-28" "platforms;android-29" "platforms;android-30" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "platforms;android-31" "platforms;android-32" "platforms;android-33" "platforms;android-34" "platforms;android-35" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager "add-ons;addon-google_apis-google-22" "add-ons;addon-google_apis-google-23" "add-ons;addon-google_apis-google-24" "skiaparser;1" "skiaparser;2" "skiaparser;3"

# Set permissions for the Android SDK directory
RUN chmod a+x -R $ANDROID_SDK_ROOT && \
    chown -R root:root $ANDROID_SDK_ROOT

# =========================================================================
# === NodeJS & Cordova Installation
# =========================================================================
# Install nvm, Node.js v22, enable Yarn, and install Cordova in a single layer
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm alias default 22 && \
    corepack enable yarn && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}

# =========================================================================
# === Verification & Cleanup
# =========================================================================
# Verify all major tool installations
RUN java -version && \
    mvn -v && \
    gradle -v && \
    ant -version && \
    node -v && \
    npm -v && \
    yarn -v && \
    cordova -v

# Perform a test Cordova build to ensure the environment is correctly configured
WORKDIR "/tmp"
RUN cordova create myApp com.myCompany.myApp myApp && \
    cd myApp && \
    cordova platform add android --save && \
    cordova requirements android && \
    cordova build android --verbose

# Final cleanup of temporary files and package caches
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/android/licenses

# Set the final working directory
WORKDIR "/tmp"