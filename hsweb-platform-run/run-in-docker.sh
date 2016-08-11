#!/usr/bin/env bash
cd hsweb-platform-run
container_name=hsweb-web-run
image_name=hsweb-web-run
server_port=8088
if [ -f "target/hsweb-platform-run.jar" ]; then
        container_id=$(docker ps -a | grep "${container_name}" | awk '{print $1}')
        if [ "${container_id}" != "" ];then
            docker stop ${container_name}
            docker rm ${container_name}
            docker rmi  ${image_name}
        fi
            docker build -t ${image_name} .
            #docker run -d -p ${server_port}:8088 --name ${container_name} ${image_name}
            docker run -d -p ${server_port}:8088 -v /opt/hsweb/db:/data -v /opt/hsweb/upload:/upload --name ${container_name} ${image_name}
    else
        echo "build error!"
        exit -1
fi
