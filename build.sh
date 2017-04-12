export MAIN_DIR=$(pwd)
cd ../
export ENV_DIR=$(pwd)
sudo apt install ccache expect libboost-dev libjansson-dev libssl-dev libyaml-cpp-dev openssl python-minimal
cd ${ENV_DIR}/
wget -q http://www.digip.org/jansson/releases/jansson-2.9.tar.gz
tar xzf jansson-2.9.tar.gz
cd ${ENV_DIR}/jansson-2.9/
./configure
make
sudo make install
cd ${ENV_DIR}/
wget -q https://www.openssl.org/source/openssl-1.1.0c.tar.gz
tar xzf openssl-1.1.0c.tar.gz
cd ${ENV_DIR}/openssl-1.1.0c
./config shared --prefix=/usr/local/ssl --openssldir=/usr/local/ssl
2>/dev/null 1>&2 make
2>/dev/null 1>&2 sudo make install
export PATH=${PATH}:/usr/local/ssl
cd ${ENV_DIR}/
git clone --quiet https://gitlab.kitware.com/cmake/cmake.git cmake
cd ${ENV_DIR}/cmake/
sed -i 's|cmake_options="-DCMAKE_BOOTSTRAP=1"|cmake_options="-DCMAKE_BOOTSTRAP=1 -DCMAKE_USE_OPENSSL=ON"|' ${ENV_DIR}/cmake/bootstrap
./bootstrap
make
sudo make install
cd ${ENV_DIR}/
wget -q https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
unzip -qq android-ndk-r13b-linux-x86_64.zip
mv android-ndk-r13b android-ndk
cd ${ENV_DIR}/
mkdir -p ${ENV_DIR}/android-sdk
cd ${ENV_DIR}/android-sdk
wget -q https://dl.google.com/android/repository/platform-tools_r25.0.2-linux.zip
unzip -qq platform-tools_r25.0.2-linux.zip
wget -q https://dl.google.com/android/repository/build-tools_r25.0.2-linux.zip
unzip -qq build-tools_r25.0.2-linux.zip
wget -q https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
unzip -qq tools_r25.2.3-linux.zip
export PATH=${PATH}:${ANDROID_HOME}/tools
export ANDROID_HOME=~/android-sdk
export ANDROID_NDK_HOME=~/android-ndk
export ANDROID_NDK=${ANDROID_NDK_HOME}
cd ~/android-sdk
echo -e "y" | ./tools/android update sdk -u -a -t platform
echo -e "y" | ./tools/android update sdk -u -a -t platform-tools
echo -e "y" | ./tools/android update sdk -u -a -t 5
echo -e "y" | ./tools/android update sdk -u -a -t source
echo -e "y" | ./tools/android update sdk -u -a -t extra
echo -e "y" | ./tools/android update sdk -u -a -t 128
cd ~/DualBootPatcher
git submodule update --init --recursive
mkdir -p ~/DualBootPatcher/build
cd ~/DualBootPatcher/build/
cmake .. -DMBP_BUILD_TARGET=android -DMBP_BUILD_TYPE=debug
make
rm -rf assets && cpack -G TXZ
make apk
export TRAVIS_CURRENT_DATE=$(date +"%d%m%y-%Hh%Mm%Ss")
ls -l ~/DualBootPatcher/Android_GUI/build/outputs/apk/Android_GUI-debug.apk
md5sum ~/DualBootPatcher/Android_GUI/build/outputs/apk/Android_GUI-debug.apk
curl --upload-file ~/DualBootPatcher/Android_GUI/build/outputs/apk/Android_GUI-debug.apk https://transfer.sh/DBP-RAK-debug-${TRAVIS_CURRENT_DATE}.apk
