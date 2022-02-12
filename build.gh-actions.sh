### Bash script for building Talkback-for-Partners Android apk
###
### The following environment variables must be set before executing this script
###   ANDROID_SDK_ROOT           # path to local copy of Android SDK
###   ANDROID_NDK_ROOT           # path to local copy of Android NDK


GRADLE_DOWNLOAD_VERSION=5.4.1
GRADLE_TRACE=false   # change to true to enable verbose logging of gradlew


function log {
  if [[ -n $1 ]]; then
    echo "##### ${1}"
  else echo
  fi
}

function fail_with_message  {
  echo
  echo "Error: ${1}"
  exit 1
}


log "pwd: $(pwd)"


if [[ -z "${ANDROID_SDK_ROOT}" ]]; then
  fail_with_message "ANDROID_SDK_ROOT environment variable is unset"
fi
log "\${ANDROID_SDK_ROOT}: ${ANDROID_SDK_ROOT}"
log "ls ${ANDROID_SDK_ROOT}"; ls "${ANDROID_SDK_ROOT}"
if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
  fail_with_message "ANDROID_NDK_ROOT environment variable is unset"
fi
log "\${ANDROID_NDK_ROOT}: ${ANDROID_NDK_ROOT}"
log "ls \${ANDROID_NDK_ROOT}:"; ls "${ANDROID_NDK_ROOT}"
log


log "java -version:"; java -version
log "javac -version:"; javac -version
log


log "Write local.properties file"
echo "sdk.dir=${ANDROID_SDK_ROOT}" > local.properties
echo "ndk.dir=${ANDROID_NDK_ROOT}" >> local.properties
log "cat local.properties"; cat local.properties
log


log "Accept SDK licenses"
yes | "${ANDROID_SDK_ROOT}"/tools/bin/sdkmanager --licenses
log


GRADLE_ZIP_REMOTE_FILE=gradle-${GRADLE_DOWNLOAD_VERSION}-bin.zip
mkdir ./.gradle_downloads/
GRADLE_ZIP_DEST_PATH=./.gradle_downloads/${GRADLE_DOWNLOAD_VERSION}.zip
log "Download gradle binary from the web ${GRADLE_ZIP_REMOTE_FILE} to ${GRADLE_ZIP_DEST_PATH} using wget"
wget -O ${GRADLE_ZIP_DEST_PATH} https://services.gradle.org/distributions/${GRADLE_ZIP_REMOTE_FILE}
log


GRADLE_UNZIP_HOSTING_FOLDER=/opt/gradle-${GRADLE_DOWNLOAD_VERSION}
log "Unzip gradle zipfile ${GRADLE_ZIP_DEST_PATH} to ${GRADLE_UNZIP_HOSTING_FOLDER}"
unzip -n -d ${GRADLE_UNZIP_HOSTING_FOLDER} ${GRADLE_ZIP_DEST_PATH}
log


GRADLE_BINARY=${GRADLE_UNZIP_HOSTING_FOLDER}/gradle-${GRADLE_DOWNLOAD_VERSION}/bin/gradle
log "\${GRADLE_BINARY} = ${GRADLE_BINARY}"
log "\${GRADLE_BINARY} -version"
${GRADLE_BINARY} -version
log "Obtain gradle/wrapper/ with gradle wrapper --gradle-version ${GRADLE_DOWNLOAD_VERSION}"
${GRADLE_BINARY} wrapper --gradle-version ${GRADLE_DOWNLOAD_VERSION}
log


log "find gradle"
find gradle
log "gradlew --version"
./gradlew --version
log


GRADLEW_DEBUG=
GRADLEW_STACKTRACE=
if [[ "$GRADLE_TRACE" = true ]]; then
  GRADLEW_DEBUG=--debug
  GRADLEW_STACKTRACE=--stacktrace
fi
log "./gradlew assembleDebug"
chmod 777 gradlew
./gradlew ${GRADLEW_DEBUG} ${GRADLEW_STACKTRACE} assemble
BUILD_EXIT_CODE=$?
log

if [[ $BUILD_EXIT_CODE -eq 0 ]]; then
  log "find . -name *.apk"
  find . -name "*.apk"
  log
fi

RELEASE_APKS_DIR=release_apks
mkdir ./${RELEASE_APKS_DIR}
mv ./build/outputs/apk/phone/release/talkback-phone-release-unsigned.apk ./${RELEASE_APKS_DIR}/TalkBack-phone.apk
mv ./build/outputs/apk/wear/release/talkback-wear-release-unsigned.apk ./${RELEASE_APKS_DIR}/TalkBack-wear.apk

exit $BUILD_EXIT_CODE   ### This should be the last line in this file
