#escape=\

# Dockerizing ColdFusion for Linux
# Dockerfile for building ColdFusion images

FROM ubuntu:16.04

# Copy required scripts and files, and set the working directory
WORKDIR /tmp/cf-install/
COPY install/setup-ubuntu-dependencies.sh install/silent.properties install/hotfix.properties /tmp/cf-install/

# Setup dependencies
RUN chmod +x setup-ubuntu-dependencies.sh; \
	sleep 1; \
	./setup-ubuntu-dependencies.sh

# Create user, and Install ColdFusion. Sleep for a second after chmod, to ensure execution occurs seamlessly
ARG installerPath
RUN useradd --system --no-create-home -r cfuser; \
 	wget --no-check-certificate $installerPath;  \
	sleep 1; \
	chmod +x ColdFusion_2016_WWEJ_linux64.bin;  \
	sleep 1; \
	service_username=cfuser;  \
	sleep 1;  \
	./ColdFusion_2016_WWEJ_linux64.bin -f silent.properties -i silent -DSILENT_RUNTIME_USER=$service_username;  \
	rm -rf ColdFusion_2016_WWEJ_linux64.bin;

# Install ColdFusion Update. 
RUN hotfix_url="https://cfdownload.adobe.com/pub/adobe/coldfusion/2016/updates/hotfix-005-303689.jar"; \
        wget --no-check-certificate $hotfix_url; \
        chmod +x ${hotfix_url##*/}; \
        sleep 1; \
        /opt/coldfusion/jre/bin/java -jar ${hotfix_url##*/} -i silent -f hotfix.properties; \
        rm -rf ${hotfix_url##*/};

# Expose ports 8500(http), 45564(Cluster Multicast Port) and 8016(ajp) from the container to the host
EXPOSE 8500 8016 45564

HEALTHCHECK --interval=3m --timeout=10s \
        CMD curl -f http://localhost:8500/ || exit 1

# Set labels for identifications
LABEL   product="2016" \
        update="5" \
        platform="Linux" \
	description="Adobe ColdFusion 2016 image" \
        version="1.0" 

# Update working directory. Remove apt caches and temp files. Create required directories
WORKDIR /opt
RUN rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/cf-install && \
	mkdir /opt/startup && \
	mkdir /opt/startup/coldfusion

# Command to execute once the container has been created 
COPY startup/start-coldfusion.sh /opt/startup
COPY startup/enableSecureProfile.cfm startup/enableSessionStorage.cfm startup/importCAR.cfm startup/enableExternalAddons.cfm /opt/startup/coldfusion/

ENTRYPOINT ["sh", "/opt/startup/start-coldfusion.sh"]
CMD ["start"]
