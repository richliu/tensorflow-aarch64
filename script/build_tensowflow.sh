#!/bin/bash

# original from 
# https://gist.github.com/muendelezaji/5a0b7d343f8656021f0ab96e50dc5c65
# =============================================================
# UPDATE SOURCE
# =============================================================
# git clone https://github.com/tensorflow/tensorflow
# git checkout -- .
# git pull origin master
# TF_BRANCH=r1.8
TF_ROOT=/root/tensorflow
TARGET_DIR=/home/work/
cd $TF_ROOT

# for python_version in python2 python3; do
for python_version in python3; do
  echo "Build TensorFlow for Python version: ${python_version}"

  # =============================================================
  # CONFIGURATION
  # =============================================================
  export PYTHON_BIN_PATH=$(which ${python_version})
  export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"
  export PYTHONPATH=${TF_ROOT}/lib
  export PYTHON_ARG=${TF_ROOT}/lib
  export USE_DEFAULT_PYTHON_LIB_PATH=1

  export TF_NEED_MKL=0
  export TF_NEED_JEMALLOC=1
  export TF_NEED_GCP=0
  export TF_NEED_HDFS=0
  export TF_ENABLE_XLA=1
  export TF_NEED_ROCM=0
  export TF_NEED_OPENCL_SYCL=0
  export TF_NEED_COMPUTECPP=0
  export TF_USE_DOUBLE_SYCL=0
  export TF_USE_HALF_SYCL=0
  export TF_NEED_CUDA=0
  export TF_NEED_VERBS=0
  export TF_NEED_MPI=0
  export TF_NEED_GDR=0
  export TF_NEED_S3=0
  export TF_NEED_KAFKA=0
  export TF_DOWNLOAD_CLANG=0
  export TF_SET_ANDROID_WORKSPACE=0

  export GCC_HOST_COMPILER_PATH=$(which gcc)
  export HOST_C_COMPILER=$(which gcc)
  export HOST_CXX_COMPILER=$(which g++)
  export CC_OPT_FLAGS="-march=native"
  # export CC_OPT_FLAGS="-march=armv8-a"

  # =============================================================
  # BUILD NEW VERSION
  # =============================================================
  bazel clean
  ./configure

  # Build TensorFlow (add -s to see executed commands)
  # "--copt=" can be "-mavx -mavx2 -mfma  -msse4.2 -mfpmath=both"
  # bazel build -c opt --copt="-O3" --copt="-funsafe-math-optimizations" --copt="-ftree-vectorize" --copt="-fomit-frame-pointer" --verbose_failures tensorflow/tools/pip_package:build_pip_package
  bazel build --copt="-mtune=native" --copt="-march=armv8-a" --copt="-O3" --config=noaws --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" --define tensorflow_mkldnn_contraction_kernel=0 --verbose_failures //tensorflow/tools/pip_package:build_pip_package 

  # Build TF pip package
  bazel-bin/tensorflow/tools/pip_package/build_pip_package ${TARGET_DIR}/tensorflow_pkg

done
