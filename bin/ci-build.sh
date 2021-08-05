#!/bin/bash

sudo apt-get install -y libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev libcups2-dev libxrandr-dev libasound2 libasound2-dev

unset -v _JAVA_OPTIONS;

$OS_BUILD="linux"
git clone --depth 1 --branch travaopenjdk https://github.com/TravaOpenJDK/openjdk-build.git;

export SOURCE_JDK_TAG=dcevm-11.0.11+1
export HSWAP_AGENT_DOWNLOAD_URL=https://github.com/HotswapProjects/HotswapAgent/releases/download/RELEASE-1.4.1/hotswap-agent-1.4.1.jar
export HSWAP_AGENT_CORE_DOWNLOAD_URL=https://github.com/HotswapProjects/HotswapAgent/releases/download/RELEASE-1.4.1/hotswap-agent-core-1.4.1.jar
export JDK_BOOT_DIR="$PWD/openjdk-build/jdk-11"
mkdir -p "$JDK_BOOT_DIR"
if [[ $OS_BUILD == "linux" ]]; then
  wget -q -O - "https://api.adoptopenjdk.net/v3/binary/version/jdk-11.0.4%2B11/linux/${FOLDER}/jdk/hotspot/normal/adoptopenjdk?project=jdk" | tar xpzf - --strip-components=1 -C ${JDK_BOOT_DIR};
  export JAVA_HOME="${JDK_BOOT_DIR}";
fi

if [[ $OS_BUILD == "osx" ]]; then
  wget -q -O - 'https://api.adoptopenjdk.net/v3/binary/version/jdk-11.0.4%2B11/mac/x64/jdk/hotspot/normal/adoptopenjdk?project=jdk' | tar xpzf - --strip-components=2 -C ${JDK_BOOT_DIR};
  export JDK_BOOT_DIR=${JDK_BOOT_DIR}/Home;
  export JAVA_HOME="${JDK_BOOT_DIR}";
fi
echo ${SOURCE_JDK_TAG}
if [[ $OS_BUILD == "linux" || $OS_BUILD == "osx" ]]; then
  bash -c "cd openjdk-build && export LOG=info && ./makejdk-any-platform.sh --tag \"${SOURCE_JDK_TAG}\" --build-variant dcevm --branch dcevm11-jdk-11.0.11-adopt --disable-test-image
    --jdk-boot-dir ${JDK_BOOT_DIR} --hswap-agent-download-url \"${HSWAP_AGENT_DOWNLOAD_URL}\" --hswap-agent-core-download-url \"${HSWAP_AGENT_CORE_DOWNLOAD_URL}\" --configure-args '-disable-warnings-as-errors'
    --target-file-name java11-openjdk-dcevm-${TRAVIS_OS_NAME}-${TRAVIS_CPU_ARCH}.tar.gz jdk11u";
fi
if [[ $OS_BUILD == "windows" ]]; then
  powershell -Command "C:\tools\cygwin\bin\bash.exe -c './build_windows.sh'";
fi