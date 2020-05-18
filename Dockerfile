FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu16.04

ARG user=flode

ENV DEBIAN_FRONTEND noninteractive
#general packages
RUN apt-get update && apt-get install -y \
sudo \
git \
nano

#OpenCV-specific packages
RUN apt-get install -y \
build-essential \
cmake \
pkg-config \
libgtk-3-dev \
libavcodec-dev \
libavformat-dev \
libswscale-dev \
libv4l-dev \
libxvidcore-dev \
libx264-dev \
libjpeg-dev \
libpng-dev \
libtiff-dev \
gfortran \
openexr \
libatlas-base-dev \
python3-dev \
python3-numpy \
libtbb2 \
libtbb-dev \
libdc1394-22-dev

RUN mkdir -p /home/$user/opencv_build
WORKDIR /home/$user/opencv_build
RUN git clone https://github.com/opencv/opencv.git
RUN git clone https://github.com/opencv/opencv_contrib.git

WORKDIR /home/$user/opencv_build/opencv_contrib
#change 'master' for your preferred opencv_contrib-version, must be same as opencv-version
RUN git checkout 3.4
WORKDIR /home/$user/opencv_build/opencv
#change 'master' for your preferred opencv-version, must be same as opencv_contrib-version
RUN git checkout 3.4
RUN mkdir -p build
WORKDIR /home/$user/opencv_build/opencv/build

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D WITH_CUDA=ON \
    -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
    -D OPENCV_EXTRA_MODULES_PATH=/home/$user/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..

#set -jX the number of CPU-cores in your machine
RUN make -j6
RUN make install

#edit this if you use opencv < 4
RUN pkg-config --modversion opencv
 	

#ROS-Installation from official ros-Dockerfile

# install packages
RUN apt-get install -q -y \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros1-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV ROS_DISTRO kinetic
# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-core=1.3.2-0* \
    ros-kinetic-ros-base=1.3.2-0* \
    ros-kinetic-perception=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*


#ROS-specific packages
RUN apt-get update && apt-get install -y \
libboost-all-dev \
ros-kinetic-usb-cam

RUN git clone --recursive https://github.com/leggedrobotics/darknet_ros.git /home/$user/catkin_ws/src/darknet_ros
WORKDIR /home/$user/catkin_ws

# edit permissions
RUN chown -R 1000:1000 /home/$user/catkin_ws

# setup entrypoint
COPY ./ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh

#ENTRYPOINT ["/ros_entrypoint.sh", "$user"]
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

