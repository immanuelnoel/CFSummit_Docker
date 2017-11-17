#!/bin/bash

# installerPath: Specifies the web accessible location of the installer
# updateDirectory: Specifies the directory from which to pick up updated Jetty directories and files 

docker build \
	--build-arg installerPath=http://<WEBSERVER>/ColdFusion_2016_Addon_linux64.bin \
	-t coldfusion:2016.0.5-addons .
