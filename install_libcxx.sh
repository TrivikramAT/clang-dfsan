VERSION=$1

wget http://releases.llvm.org/${VERSION}/libcxx-${VERSION}.src.tar.xz
wget http://releases.llvm.org/${VERSION}/libcxxabi-${VERSION}.src.tar.xz
tar -xf libcxx-${VERSION}.src.tar.xz && rm libcxx-${VERSION}.src.tar.xz
tar -xf libcxxabi-${VERSION}.src.tar.xz && rm libcxxabi-${VERSION}.src.tar.xz
mv libcxx-${VERSION}.src libcxx
mv libcxxabi-${VERSION}.src libcxxabi

mkdir build_libcxxabi
cd build_libcxxabi

FLAGS="-fsanitize=dataflow -fsanitize-blacklist=/dfsan_abilist.txt"

cmake \
  -DCMAKE_BUILD_TYPE=MinSizeRel\
  -DCMAKE_INSTALL_PREFIX=/opt/libcxx\
  -DCMAKE_C_COMPILER=clang\
  -DCMAKE_CXX_COMPILER=clang++\
  -DLLVM_PATH=/opt/llvm/lib\
  -DCMAKE_C_FLAGS="$FLAGS"\
  -DCMAKE_CXX_FLAGS="$FLAGS"\
  -DLIBCXXABI_ENABLE_SHARED=NO\
  -DLIBCXXABI_LIBCXX_PATH=../libcxx\
  -DLIBCXXABI_USE_LLVM_UNWINDER=On\
  ../libcxxabi
make -j${NCPUS} install

cd ..

mkdir build_libcxx
cd build_libcxx

cmake \
  -DCMAKE_BUILD_TYPE=MinSizeRel\
  -DCMAKE_INSTALL_PREFIX=/opt/libcxx\
  -DCMAKE_C_COMPILER=clang\
  -DCMAKE_CXX_COMPILER=clang++\
  -DCMAKE_C_FLAGS="$FLAGS"\
  -DCMAKE_CXX_FLAGS="$FLAGS"\
  -DLIBCXX_ENABLE_SHARED=OFF\
  -DLIBCXX_CXX_ABI=libcxxabi\
  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON\
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../libcxxabi/include/\
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=../build_libcxxabi/lib/\
  ../libcxx
make -j${NCPUS} install

