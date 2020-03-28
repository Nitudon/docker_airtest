FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common \
                       tzdata

RUN apt-add-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git \
                       unzip

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc

RUN echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev \
                       libbz2-dev libreadline-dev libsqlite3-dev wget \
                       curl llvm libncurses5-dev xz-utils tk-dev \
                       libxml2-dev libxmlsec1-dev libffi-dev

ENV PATH $PATH:/root/.pyenv/bin

RUN pyenv install 3.7.0 && \
    pyenv global 3.7.0 && \
    pyenv rehash

ENV PATH $PATH:/root/.pyenv/shims

RUN pip install --upgrade pip && \
    pip install -U airtest

# Install Java
RUN apt-get install -y wget openjdk-8-jdk-headless libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 zlib1g lib32z1 git redir && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android
ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# Environment variables
ENV PATH $PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

# Make license agreement
RUN mkdir $ANDROID_HOME/licenses && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
    echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Update and install using sdkmanager
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools" "platform-tools" && \
    $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" "build-tools;27.0.3" && \
    $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28" "platforms;android-27" && \
    $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"