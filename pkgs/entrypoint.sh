#!/bin/bash


source ~/miniconda3/etc/profile.d/conda.sh
conda activate ComfyUI

exec /usr/bin/tini -- $@


