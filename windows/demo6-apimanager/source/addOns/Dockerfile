#escape=\

# Dockerizing ColdFusion API Manager Addons for Linux - Includes Redis, ElasticSearch
# Dockerfile for building ColdFusion API Manager Addon images

FROM ubuntu:16.04

# Copy required scripts and files, and set the working directory
WORKDIR /tmp/apim-install/
COPY install/setup-ubuntu-dependencies.sh install/silent.properties /tmp/apim-install/ 

# Setup platform dependencies
RUN chmod +x setup-ubuntu-dependencies.sh; \
        sleep 1; \
        ./setup-ubuntu-dependencies.sh; 

ARG installerPath
# Create user, and install API Manager Addons. Sleep for a second after chmod, to ensure execution occurs seamlessly
RUN useradd --system --no-create-home -r apimuser; \
        wget --no-check-certificate $installerPath;  \
        sleep 1; \
        chmod +x ColdFusionAPIManagerAddON_2016_WWEJ_linux64.bin;  \
        sleep 1; \
        service_username=apimuser;  \
        sleep 1;  \
        ./ColdFusionAPIManagerAddON_2016_WWEJ_linux64.bin -f silent.properties -i silent -DSILENT_RUNTIME_USER=$service_username;  \
        rm -rf ColdFusionAPIManagerAddON_2016_WWEJ_linux64.bin; 

# Expose ports 8989 (jetty) from the container to the host
EXPOSE 6379 9200 9300 

# Set labels for identifications
LABEL   product="2016" \
        update="5" \
        platform="Linux" \
	type="addons" \
        description="Addons for Adobe ColdFusion API Manager 2016" \
        version="1.0"

# Update working directory
WORKDIR /opt

# Remove apt caches and temp files. Create required directories
RUN rm -rf /var/lib/apt/lists/* && \
        rm -rf /tmp/cf-install && \
        mkdir /opt/startup

# Command to execute once the container has been created
COPY startup/start-addons.sh /opt/startup

ENTRYPOINT ["sh", "/opt/startup/start-addons.sh"]
CMD ["start"]
