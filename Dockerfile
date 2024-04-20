ARG ROS_DISTRO=humble

# Pull ROS2 Humble desktop image from OSRF
FROM sky360/ros2-humble-full:latest

# Install packages 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    # Text editors
    nano \
    gedit \
    # Terminal utilities
    terminator \
    net-tools \
    iputils-ping \
    # ROS tools
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-rqt* \
    # pip
    python3-pip \
    python3-serial \
    ros-${ROS_DISTRO}-usb-cam \
    mpv \
    # Clear apt lists
    # Good practice to always clear apt lists after installing
    # packages or run apt-get update (prevent conflicting packages).
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=syt
ARG USER_UID=1001
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/${USERNAME}/.config

RUN usermod -aG dialout ${USERNAME}
# Set up sudo access for the user
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/${USERNAME} \
  && rm -rf /var/lib/apt/lists/*

# Set up .bashrc scripts
# This script will be executed everytime you create a new terminal
    ## Source ROS folder
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc \
    # ## Source Gazebo folder
    # && echo "source /usr/share/gazebo/setup.sh" >> /home/${USERNAME}/.bashrc \
    # ## Select turtlebot model to burger
    # && echo "export TURTLEBOT3_MODEL=burger" >> /home/${USERNAME}/.bashrc \
    # ## Add turtlebot models to Gazebo model path
    # && echo "export GAZEBO_MODEL_PATH=\$GAZEBO_MODEL_PATH:/opt/ros/${ROS_DISTRO}/share/turtlebot3_gazebo/models" >> /home/${USERNAME}/.bashrc \ 
    ## Prevent ROS2 DDS to be discovered on network
    && echo "export ROS_LOCALHOST_ONLY=1" >> /home/${USERNAME}/.bashrc

# Setup default work directory
WORKDIR /home/${USERNAME}

CMD ["bash"]