# Ubuntu 18.04 is the base image
FROM nvidia/cuda:11.1-cudnn8-devel-ubuntu18.04
LABEL maintainer="Shubham Turai <shubham.turai@robotic-eyes.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Install required packages for ARM build
# -y [yes] -q [quiet]
RUN apt-get update -y && \
    apt-get install -y \
    python3-pip python3-dev python3-venv \
    python3-numpy \
    libsm6 libxext6 libxrender-dev \
    git \
    ffmpeg \
    unzip \
    build-essential pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev \
    libtbb2 libtbb-dev libdc1394-22-dev\
    wget

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ARG DOWNLOAD_ALL=0
ARG OPENMP=0
# To save you a headache
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
RUN pip3 install --upgrade pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq python3-opencv
RUN apt-get install -y libopencv-dev clang-format apt-utils libopencv-highgui-dev \
			autoconf automake libtool libgtk-3-dev

# Install CMake 3.18.4
RUN version=3.18 && build=4\
   && mkdir ~/temp-cmake \
   && cd ~/temp-cmake \
   && wget https://cmake.org/files/v$version/cmake-$version.$build-Linux-x86_64.sh \
   && mkdir /opt/cmake \
   && sh cmake-$version.$build-Linux-x86_64.sh --prefix=/opt/cmake --skip-license \
   && for filename in /opt/cmake/bin/*; do echo Registering $filename; \
   ln -fs $filename /usr/local/bin/`basename $filename`; done \
   && rm -f cmake-$version.$build-Linux-x86_64.sh

RUN pip3 install setuptools
RUN pip3 install numpy
RUN pip3 install requests
RUN pip3 install llvmlite==0.31.0
RUN pip3 install numba==0.49.1
RUN pip3 install imutils


# Install the packages required for ImageAugmentor
RUN pip3 install albumentations tqdm --use-feature=2020-resolver
# Install source-build OpenCV
RUN mkdir -p ~/opencv_build && cd ~/opencv_build &&\
    git clone https://github.com/opencv/opencv.git &&\
    git clone https://github.com/opencv/opencv_contrib.git

RUN cd ~/opencv_build/opencv && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_CUDA=ON \
    -D BUILD_PERFORMANCE_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D ENABLE_FAST_MATH=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D CUDA_ARCH_BIN=7.5 \
    -D WITH_CUBLAS=1 \
    -D CUDA_FAST_MATH=1 \
    -D WITH_GTK=ON \
    -D BUILD_SHARED_LIBS=ON .. \
#    -D WITH_CUDNN=ON \
#    -D BUILD_opencv_cudacodec=OFF \
    && make  -j16 \
    && make install

RUN /bin/bash -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf' && ldconfig

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
  doxygen \
    file \
    gfortran \
    gnupg \
    gstreamer1.0-plugins-good \
    imagemagick \
    libatk-adaptor \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libboost-all-dev \
    libcanberra-gtk-module \
    libdc1394-22-dev \
    libeigen3-dev \
    libfaac-dev \
    libfreetype6-dev \
    libgflags-dev \
    libglew-dev \
    libglu1-mesa \
    libglu1-mesa-dev \
    libgoogle-glog-dev \
    libgphoto2-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-bad1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libgtk2.0-dev \
    libgtk-3-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    libjpeg-dev \
    liblapack-dev \
    libmp3lame-dev \
    libopenblas-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenjp2-7-dev \
    libopenjp2-tools \
    libpng-dev \
    libpostproc-dev \
    libprotobuf-dev \
    libpython3-dev \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libtheora-dev \
    libtiff5-dev \
    libv4l-dev \
    libvorbis-dev \
    libx264-dev \
    libxi-dev \
    libxine2-dev \
    libxmu-dev \
    libxvidcore-dev \
    libzmq3-dev \
    python3-tk \
    python-imaging-tk \
    python-lxml \
    python-pil \
    python-tk \
    v4l-utils \
    x11-apps \
    x264 \
    yasm

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
  cuda-samples-11-1 \
  vim

# for tensorflow-yolov4-tflite
RUN pip3 install tensorflow==2.3.0rc0 absl-py matplotlib easydict pillow --use-feature=2020-resolver
RUN apt-get install -y jq gdb

# RUN apt-get install curl zip tar

# RUN git clone https://github.com/microsoft/vcpkg

# RUN ./vcpkg/bootstrap-vcpkg.sh
# RUN ./vcpkg/vcpkg install boost-filesystem

WORKDIR /home
RUN cmake --version
RUN pkg-config --cflags opencv
RUN pkg-config --libs opencv

CMD ["/bin/sh"]