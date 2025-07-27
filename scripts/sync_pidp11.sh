#!/bin/bash
rsync --delete --exclude=.git --exclude=builds -avz ./ geoff@pidp11.lab.asio:packer