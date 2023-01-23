FROM ubuntu:20.04

LABEL maintainer="atik@we2app.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Base Image" \
      org.label-schema.description="Base Image for all images - base on Ubuntu 20.04" 
      
ENV DEBIAN_FRONTEND=noninteractive \
      TERM=xterm

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Install Java
RUN apt-get update && \
    apt-get -y install openjdk-11-jdk-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    java -version && \
    export JAVA_HOME=$(dirname $(dirname $(update-alternatives --list java)))

# Install NodeJS
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-key fingerprint 1655A0AB68576280 && \
    export VERSION=node_14.x && \
    export DISTRO="$(lsb_release -s -c)" && \
    echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    node -v && npm -v && \
    npm install -g yarn && \
    yarn -v && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Install Ant, Maven, Gradle
RUN apt-get update && \
    apt-get -qq install -y wget curl maven ant gradle && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN apt-get update && \
    apt-get -y install unzip && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip && \
    unzip commandlinetools-linux-9123335_latest.zip -d /opt/android-sdk && \
    rm commandlinetools-linux-9123335_latest.zip && \
    mkdir -p /root/.android && touch /root/.android/repositories.cfg && \
    mkdir -p /opt/android-sdk/cmdline-tools/latest && \
    mv /opt/android-sdk/cmdline-tools/* /opt/android-sdk/cmdline-tools/latest | mkdir latest && \
    yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses && \
    /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "extras;android;m2repository" "extras;google;m2repository" && \
    export ANDROID_HOME=/opt/android-sdk && \
    export ANDROID_SDK_ROOT=/opt/android-sdk && \
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/:$ANDROID_HOME/platform-tools && \
    echo "export ANDROID_HOME=/opt/android-sdk" >> ~/.bashrc && \
    echo "export ANDROID_SDK_ROOT=/opt/android-sdk" >> ~/.bashrc && \
    echo "export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/:$ANDROID_HOME/platform-tools" >> ~/.bashrc

WORKDIR "/tmp"

RUN npm i -g --unsafe-perm cordova@11.0.0 && \
    export ANDROID_HOME=/opt/android-sdk && \
    export ANDROID_SDK_ROOT=/opt/android-sdk && \
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/:$ANDROID_HOME/platform-tools && \
    cordova -v && \
    cd /tmp && \
    cordova create myApp com.myCompany.myApp myApp && \
    cd myApp && \
    cordova platform add android --save && \
    cordova requirements android && \
    cordova build android --verbose && \
    rm -rf /tmp/myApp























# FROM we2app/android

# ENV CORDOVA_VERSION 11.0.0


# RUN apt-get update && apt-get install -y curl gnupg2 lsb-release && \
#     curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
#     apt-key fingerprint 1655A0AB68576280 && \
#     export VERSION=node_16.x && \
#     export DISTRO="$(lsb_release -s -c)" && \
#     echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list && \
#     echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
#     apt-get update && apt-get install -y nodejs && \
#     node -v && npm -v && \
#     npm install -g yarn && \
#     yarn -v && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*. 


# WORKDIR "/tmp"

# RUN npm i -g --unsafe-perm cordova@11.0.0 && \
#     cordova -v && \
#     cd /tmp && \
#     cordova create myApp com.myCompany.myApp myApp && \
#     cd myApp && \
#     cordova platform add android --save && \
#     cordova requirements android && \
#     cordova build android --verbose && \
#     rm -rf /tmp/myApp