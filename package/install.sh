#!/bin/bash

yum install -y -e0 pandoc

cp -R data/* "${cw_ROOT}"
