#!/bin/bash

docker run -p 127.0.0.1:53:53 -p 127.0.0.1:53:53/udp --restart=always $1
