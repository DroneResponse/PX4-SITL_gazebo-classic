FROM ros:noetic-robot
RUN mkdir -p /catkin_ws/src/sitl_gazebo


# Install Gazebo and its dependencies
RUN apt-get update && apt-get install -y \
    gazebo11 \
    libgazebo11-dev \
    libgstreamer1.0-dev \
    libopencv-dev \
    libeigen3-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libprotoc-dev \
    libgstreamer-plugins-base1.0-dev \
    python3-dev \
    python3-pip \
    git \
    wget \
    python3-setuptools \
    build-essential \
    cmake \
    libjansson-dev

RUN pip3 install Jinja2

# Clone PX4-SITL_gazebo-classic repository with the dev-devcontainer branch
RUN git clone --recursive -b dev-devcontainer https://github.com/DroneResponse/PX4-SITL_gazebo-classic.git

# Set working directory
WORKDIR /PX4-SITL_gazebo-classic

# Clone mavlink
RUN git clone https://github.com/mavlink/mavlink.git --recursive

# installing mavlink headers
RUN cd mavlink \ 
    && python3 -m pip install -r pymavlink/requirements.txt \
    && python3 -m pymavlink.tools.mavgen --lang=C --wire-protocol=2.0 --output=generated/include/mavlink/v2.0 message_definitions/v1.0/common.xml \
    && cmake -Bbuild -H. -DCMAKE_INSTALL_PREFIX=install -DMAVLINK_DIALECT=common -DMAVLINK_VERSION=2.0 \
    && cmake --build build --target install

# clone mavlink c_library_v2
RUN git clone https://github.com/mavlink/c_library_v2.git

RUN cp -r c_library_v2/development mavlink/install/include/mavlink/

# COPY CMakeLists.txt .
# COPY src/gazebo_camera_manager_plugin.cpp ./src/
# COPY src/gazebo_gimbal_controller_plugin.cpp ./src/



# Create build directory and run CMake
RUN mkdir build && cd build && cmake ..