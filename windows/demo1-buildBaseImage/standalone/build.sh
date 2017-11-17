#!/bin/bash

# installerPath: Specifies the web accessible location of the installer

docker build --build-arg installerPath=http://<WEBSERVER>/ColdFusion_2016_WWEJ_linux64.bin -t coldfusion:2016.0.5 .
