#!/bin/bash

# installerPath: Specifies the web accessible location of the installer
# updateDirectory: Specifies the directory from which to pick up updated Jetty directories and files 

docker build \
	--build-arg installerPath=http://<WEBSERVER>/ColdFusionAPIManagerAddON_2016_WWEJ_linux64.bin \
	-t apimanager:2016.0.1-addons .
