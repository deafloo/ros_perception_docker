#!/bin/bash
#set -e

#echo "User: $1"
# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
#source "/home/$0/catkin_ws/devel/setup.bash"
exec "$@"
