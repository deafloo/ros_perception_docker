#!/bin/bash

export UID=$(id -u)
export GID=$(id -g)

imageTag=ros:kinetic_darknet		#as described at the docker-build-process
imageName=ros_perception_docker		#name of the Docker-container

isRunning="$(docker inspect -f '{{.State.Running}}' $imageName)" > /dev/null 2>&1	#suppress console output
imageStatus="$(docker inspect -f '{{.State.Status}}' $imageName)" > /dev/null 2>&1
detectMaster="$(docker inspect -f '{{.State.Running}}' ros_kinetic_master)" > /dev/null 2>&1

if [ $detectMaster ]
then
	read -p "Rosmaster detected. Would you like to connect to ROS-Network (y/n)? " answer
	case ${answer:0:1} in
		y|Y )
			#Start with ROS-Network
			if [ ! $isRunning ]
			then
				echo "Starting new container..."
				
				sudo docker run \
					-it \
					--gpus all \
					--name=$imageName \
					--net ros_network \
					--user=$UID:$GID \
					--env ROS_HOSTNAME=$imageName \
					--env ROS_MASTER_URI=http://ros_kinetic_master:11311 \
					--env DISPLAY=$DISPLAY \
					--env="QT_X11_NO_MITSHM=1" \
					--volume="/etc/group:/etc/group:ro" \
					--volume="/etc/passwd:/etc/passwd:ro" \
					--volume="/etc/shadow:/etc/shadow:ro" \
					--volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
					--volume="/home/$USER/.ros:/home/$USER/.ros:rw" \
					--volume="/home/$USER/.bashrc:/home/$USER/.bashrc:ro" \
					--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
					--device="/dev/video0:/dev/video0" \
					--volume="/home/$USER/Object_detection/weights:/home/$USER/darknet/weights:ro" \
					--volume="/home/$USER/Object_detection/darknet_konsti:/home/$USER/Object_detection/darknet_konsti:ro" \
					--workdir="/home/$USER/catkin_ws" \
					$imageTag
			fi
		;;
		* )
			#Start Container without ROS-Network
			if [ ! $isRunning ]
			then
				echo "Starting new container with roscore in background"
				echo "Please kill docker container after use"
				
				sudo docker run \
					-d \
					--gpus all \
					--name=$imageName \
					--user=$UID:$GID \
					--env DISPLAY=$DISPLAY \
					--env="QT_X11_NO_MITSHM=1" \
					--volume="/etc/group:/etc/group:ro" \
					--volume="/etc/passwd:/etc/passwd:ro" \
					--volume="/etc/shadow:/etc/shadow:ro" \
					--volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
					--volume="/home/$USER/.ros:/home/$USER/.ros:rw" \
					--volume="/home/$USER/.bashrc:/home/$USER/.bashrc:ro" \
					--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
					--device="/dev/video0:/dev/video0" \
					--volume="/home/$USER/Object_detection/weights:/home/$USER/darknet/weights:ro" \
					--volume="/home/$USER/Object_detection/darknet_konsti:/home/$USER/Object_detection/darknet_konsti:ro" \
					--workdir="/home/$USER/catkin_ws" \
					$imageTag \
					/bin/bash -c "catkin_make -DCMAKE_BUILD_TYPE=Release; roscore"

				echo "Starting interactive terminal..."

				xhost +
				sudo docker exec \
					-it \
					$imageName \
					bash
				xhost -
			fi
		;;
		esac

	if [ "$imageStatus" == "exited" ]
	then
		xhost + 
		sudo docker start \
			$imageName
		xhost -
	else
		xhost +
		sudo docker exec \
			-it \
			$imageName \
			bash
		xhost -
	fi


else #if Master is not detected -> just launch container as usual
	if [ ! $isRunning ]
			then
				echo "Starting new container with roscore in background"
				echo "Please kill docker container after use"
				
				sudo docker run \
					-d \
					--gpus all \
					--name=$imageName \
					--user=$UID:$GID \
					--env DISPLAY=$DISPLAY \
					--env="QT_X11_NO_MITSHM=1" \
					--volume="/etc/group:/etc/group:ro" \
					--volume="/etc/passwd:/etc/passwd:ro" \
					--volume="/etc/shadow:/etc/shadow:ro" \
					--volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
					--volume="/home/$USER/.ros:/home/$USER/.ros:rw" \
					--volume="/home/$USER/.bashrc:/home/$USER/.bashrc:ro" \
					--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
					--device="/dev/video0:/dev/video0" \
					--volume="/home/$USER/Object_detection/weights:/home/$USER/darknet/weights:ro" \
					--volume="/home/$USER/Object_detection/darknet_konsti:/home/$USER/Object_detection/darknet_konsti:ro" \
					--workdir="/home/$USER/catkin_ws" \
					$imageTag \
					/bin/bash -c "catkin_make -DCMAKE_BUILD_TYPE=Release; roscore"

				echo "Starting interactive terminal..."

				xhost +
				sudo docker exec \
					-it \
					$imageName \
					bash
				xhost -
	elif [ "$imageStatus" == "exited" ]
	then
		xhost + 
		sudo docker start \
			$imageName
		xhost -
	else
		xhost +
		sudo docker exec \
			-it \
			$imageName \
			bash
		xhost -
	fi
fi
	
