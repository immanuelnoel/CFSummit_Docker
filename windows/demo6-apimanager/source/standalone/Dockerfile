#escape=\

# Dockerizing ColdFusion API Manager for Linux
# Dockerfile for building ColdFusion API Manager images

FROM ubuntu:16.04

# Copy required scripts and files, and set the working directory
WORKDIR /tmp/apim-install/
COPY install/setup-ubuntu-dependencies.sh install/silent.properties install/hotfix.properties /tmp/apim-install/ 

# Setup dependencies
RUN chmod +x setup-ubuntu-dependencies.sh; \
        sleep 1; \
        ./setup-ubuntu-dependencies.sh

# Create user, and install ColdFusion API Manager. Sleep for a second after chmod, to ensure execution occurs seamlessly
ARG installerPath
RUN useradd --system --no-create-home -r apimuser; \
	wget --no-check-certificate $installerPath;  \
	sleep 1; \
	chmod +x ColdFusionAPIManager_2016_WWEJ_linux64.bin;  \
	sleep 1; \
	service_username=apimuser;  \
	sleep 1;  \
	./ColdFusionAPIManager_2016_WWEJ_linux64.bin -f silent.properties -i silent -DRUNTIME_USER=$service_username -DRUNTIME_USER_1=$service_username;  \
	rm -rf ColdFusionAPIManager_2016_WWEJ_linux64.bin;

# Install API Manager Update.
RUN hotfix_url="https://cfdownload.adobe.com/pub/adobe/apimanager/updates/pub/hotfix-001-302960.jar"; \
        wget --no-check-certificate $hotfix_url; \
        chmod +x ${hotfix_url##*/}; \
        sleep 1; \
        /opt/coldfusionapimanager/jre/bin/java -jar ${hotfix_url##*/} -i silent -f hotfix.properties; \
        rm -rf ${hotfix_url##*/};

# Expose ports 9000(portal), 9100(proxy) and 9151,9251(ajp) from the container to the host
EXPOSE 9000 9100 9151 9251

HEALTHCHECK --interval=3m --timeout=10s \
	CMD curl -f http://localhost:9000/portal || exit 1

# Set labels for identifications
LABEL   product="2016" \
        update="1" \
        platform="Linux" \
	description="Adobe ColdFusion 2016 API Manager image" \
        version="1.0" 

# Update working directory. Remove apt caches and temp files. Create required directories
WORKDIR /opt
RUN rm -rf /var/lib/apt/lists/* && \
        rm -rf /tmp/cf-install && \
        mkdir /opt/startup && \
        mkdir /opt/startup/apimanager

# Command to execute once the container has been created
COPY startup/start-apim.sh /opt/startup

ENTRYPOINT ["sh", "/opt/startup/start-apim.sh"]
CMD ["start"]
