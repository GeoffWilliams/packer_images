#!/bin/bash
rsync --delete --exclude=.git --exclude=builds -avz ./ atlas.servers.asio:/data/ssd/share/packer