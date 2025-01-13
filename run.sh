#!/bin/bash


path=$(cd `dirname $0`; pwd)


models="$path/models"
input="$path/input"
output="$path/output"
workflows="$path/workflows"
dirs=(
    $models
    $input
    $output
    $workflows
)
for i in ${dirs[@]}
do
    if [ ! -d "$i" ]; then
        mkdir -p $i
    fi
    chown 5000:5000 $i -R
done


function run() {
    docker run -d --restart=unless-stopped --name comfyui --gpus all -p 8188:8188 -p 2222:22 \
        -v $models:/home/ui/ComfyUI/models \
        -v $input:/home/ui/ComfyUI/input \
        -v $output:/home/ui/ComfyUI/output \
        -v $workflows:/home/ui/ComfyUI/user/default/workflows \
        comfyui:v0.3.10
}


if [ `docker ps -a|grep comfyui -c 2>/dev/null` == "0" ]; then
    run
else
    echo "Containers comfyui is existed."
fi


