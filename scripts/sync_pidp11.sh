#!/bin/bash
rsync --delete --exclude=.git --exclude=builds -avz ./ geoff@pidp11.untrusted.asio:packer