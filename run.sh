#!/bin/bash

DOCKER_IMG_NAME="alexprivalov/intellij-cpp"
TAG="debian8"
docker_image_name="${DOCKER_IMG_NAME}:${TAG}"

set -e

script() {
    [ "$#" -lt 1 ] && ( usage && exit 0 ) || main "$@"
}


function main {
    docker_user_home="docker-user"

    additional_docker_options="--privileged -it\
                                -v /var/run/dbus/:/var/run/dbus/ \
                                -v /tmp/.X11-unix:/tmp/.X11-unix \
                                -v /dev/snd:/dev/snd \
                                -e DISPLAY=unix$DISPLAY \
                                -v $HOME:/home/${docker_user_home}"
    source_dir=$1

    resolved_dir=$(readlink -f $source_dir)
    echo "host source_dir: '${resolved_dir}'"

    if [ -z "$(docker ps -a| grep `whoami`_`basename ${resolved_dir}`)" ]; then
        container_counter=1
    else
        container_counter="$(docker ps -a| grep `whoami`_`basename ${resolved_dir}` | awk -F "_" '{print $NF}' | sort -nr | head -n1)"
        container_counter=$((container_counter+1))
    fi

    container_img="`whoami`_`basename ${resolved_dir}`_$container_counter"

    hint_msg=$(echo -e "\
        ################################################################################\n\
        # Docker image: ${docker_image_name}                                            \n\
        # Will mount host path \"${resolved_dir}\" to container path \"${resolved_dir}\"\n\
        # The source is available at \"${resolved_dir}\".                               \n\
        # Type "Ctrl+D" to exit from container.                                         \n\
        # root password: \"root\"                                                       \n\
        ################################################################################\n\
    ")

    bash_cmd=$(echo -e "\
    echo '${hint_msg}' \
    && cd ${resolved_dir} \
    && bash \
    ")
    
    docker pull ${docker_image_name}
    containers_to_del=$(docker ps -a -f status=exited | grep ${docker_image_name} | awk '{ print $1 }')
    if [ ! -z "${containers_to_del}" ]; then
        echo ""
        echo "Will remove ${docker_image_name}* stopped containers:"
        echo "`docker ps -a -f status=exited | grep ${docker_image_name} | awk '{ print $1, $2 }'`"
        echo ""
        docker rm $(docker ps -a -f status=exited | grep ${docker_image_name} | awk '{ print $1 }') || true #remove stopped containers
    fi

    imgs_for_del=$(docker images -f "dangling=true" -q)
    if [ ! -z "${imgs_for_del}" ]; then
        echo "Will remove dangling layers"
        docker rmi $(docker images -f "dangling=true" -q) || true #clean docker dangling images with <none>:<none>
        echo ""
    fi
    
    docker run --rm ${additional_docker_options} \
                    -v ${resolved_dir}:${resolved_dir} \
                    --net=host \
                    -e LOCAL_USER_ID=`id -u ${USER}` \
                    --name $container_img \
                    ${docker_image_name} \
                    bash -c "${bash_cmd}"
}                

function usage {
    self_script_name="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
    echo
    echo "Usage: "
    echo "      ${self_script_name} path_to_directory_with_sources"
    echo "Examples: "
    echo "      ${self_script_name} .                                         #get bash inside current host working directory"
    echo "      ${self_script_name} /home/user/develop                        #run container with mounted /home/user/develop directory inside"
}

script "$@"
