FROM we2app/android:34.0.0

LABEL maintainer="atik@we2app.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="cordova 12 image" \
      org.label-schema.description="cordova 12 image" 


# Install NodeJS
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-key fingerprint 1655A0AB68576280 && \
    export VERSION=node_18.x && \
    export DISTRO="$(lsb_release -s -c)" && \
    echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list && \
    echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    node -v && npm -v && \
    npm install -g yarn && \
    yarn -v && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CORDOVA_VERSION=12.0.0 \
    CORDOVA_BUILD_TOOLS_VERSION=33.0.2 \
    ANDROID_HOME=/opt/android

WORKDIR "/tmp"

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    cordova -v && \
    cd /tmp && \
    cordova create myApp com.myCompany.myApp myApp && \
    cd myApp && \
    cordova plugin add cordova-plugin-camera --save && \
    cordova platform add android --save && \
    cordova requirements android && \
    cordova build android --verbose && \
    rm -rf /tmp/myApp && \
    rm -rf /opt/android/licenses

# demo app
# RUN cordova create myApp com.myCompany.myApp myApp && \
#     cd myApp && \
#     cordova platform add android --save && \
#     cordova requirements android && \
#     cordova build android --verbose && \
#     rm -rf /tmp/myApp
















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