#!/bin/bash

docker run -it --rm -p 8080:8080  model_server:latest bash #-v `pwd`:/home/developer model_server:latest bash