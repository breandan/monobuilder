FROM arm32v7/ros:kinetic-ros-base-xenial

MAINTAINER Breandan Considine breandan.considine@nutonomy.com

# Switch on systemd init system in container and set various other variables
ENV QEMU_EXECVE 1 \
    INITSYSTEM="on" \
    TERM="xterm" \
    ROS_DISTRO="kinetic"

COPY bin/ /usr/bin/

RUN [ "cross-build-start" ]

# Add ROS apt repository
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 0xB01FA116

RUN apt-get clean && apt-get update && apt-get upgrade -y

# ROS Dependencies
RUN apt-get install -yq --no-install-recommends --fix-missing \
    ros-kinetic-robot=1.3.2-0* ros-kinetic-perception=1.3.2-0* \
    ros-kinetic-navigation ros-kinetic-robot-localization \
    ros-kinetic-roslint ros-kinetic-hector-trajectory-server \
    ros-kinetic-ros-tutorials ros-kinetic-common-tutorials

# System dependencies
RUN apt-get install -yq --no-install-recommends --fix-missing \
    sudo locales locales-all build-essential i2c-tools net-tools iputils-ping man \
    etckeeper emacs vim byobu zsh git git-extras htop atop nethogs iftop apt-file ntpdate gfortran \
    libxslt-dev libxml2-dev \
    libblas-dev liblapack-dev libatlas-base-dev libyaml-cpp-dev libpcl-dev libvtk6-dev libboost-all-dev

# Python Dependencies
# https://github.com/duckietown/duckuments/blob/dd3c5229526bcbb3e2f6cacc813b1313e7a4dbbc/docs/atoms_17_opmanual_duckiebot/atoms_17_setup_duckiebot_DB17-jwd/1_1_reproducing_ubuntu_image.md#install-packages
RUN apt-get install -yq --no-install-recommends --fix-missing \
    python-pip \
    python-dev ipython python-sklearn python-smbus python-termcolor python-tables python-frozendict \
    python-lxml python-bs4 python-openssl python-service-identity python-rosdep python-catkin-tools 

# Cleanup packages list
RUN apt-get clean && rm -rf /var/lib/apt/lists

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN pip install --upgrade pip wheel

RUN pip install --upgrade \
    platformio pillow networkx \
    PyContracts==1.7.15 \
    DecentLogs==1.1.2 \
    QuickApp==1.3.8 \
    conftools==1.9.1 \
    comptests==1.4.10 \
    procgraph==1.10.6 \
    pymongo==3.5.1 \
    ruamel.yaml==0.15.34

RUN rosdep update

RUN mkdir /home/software
COPY . /home/software/

# RUN /bin/bash -c "source /home/software/environment.sh && catkin_make -C /home/software/catkin_ws/"

RUN echo $'\n\
    source /home/software/environment.sh \n\
    export DUCKIEFLEET_ROOT=/home/duckiefleet \n\
    cd /home/software \n\
    ' >> ~/.bashrc

RUN git clone https://github.com/duckietown/duckiefleet /home/duckiefleet

# RUN /bin/bash -c "source /home/software/environment.sh && make build-machines"


RUN [ "cross-build-end" ]
