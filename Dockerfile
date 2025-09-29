# Ubuntu 22.04 + ROS 2 Humble desktop (x86_64)
FROM osrf/ros:humble-desktop

# Workspace
WORKDIR /work

# GUI env for RViz2 etc.
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
SHELL ["/bin/bash", "-c"]

# Useful tools & ROS 2 build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip python3-venv \
    build-essential git curl wget usbutils udev \
    python3-colcon-common-extensions \
    ros-humble-rmw-fastrtps-cpp \
    ros-humble-ros-base \
    iproute2 iputils-ping net-tools \
    && rm -rf /var/lib/apt/lists/*

# Python utilities (optional)
RUN pip3 install --no-cache-dir pyserial requests

# Create user to match host UID/GID so mounted files have sane permissions
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} abc_group \
 && useradd -m -u ${USER_ID} -g ${GROUP_ID} robot \
 && usermod -aG dialout,video robot \
 && echo "robot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER robot

# Source ROS 2 and (later) the workspace overlay
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc \
 && echo "if [ -f /work/install/setup.bash ]; then source /work/install/setup.bash; fi" >> ~/.bashrc


# ENTRYPOINT [ "bash", "-c", "source /opt/ros/humble/setup.bash && colcon build --symlink-install && exec bash" ]

# Ensure the workspace layout exists at runtime and attempt a build if packages are present.
# If no packages yet, we just drop to a shell with ROS 2 sourced.
ENTRYPOINT [ "bash", "-lc", "\
  source /opt/ros/humble/setup.bash && \
  mkdir -p /work/src && \
  if [ -n \"$(ls -A /work/src 2>/dev/null)\" ]; then \
    sudo rosdep update || true; \
    sudo rosdep install --from-paths src --ignore-src -r -y || true; \
    colcon build --symlink-install || true; \
  else \
    echo 'No packages found in /work/src yet. Place ROS 2 packages there and run: colcon build'; \
  fi; \
  exec bash" ]
