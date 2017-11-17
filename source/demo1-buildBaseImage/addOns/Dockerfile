#escape=\

# Dockerizing ColdFusion Addons for Linux - Includes Jetty, Solr, PDF
# Dockerfile for building ColdFusion Addon images

FROM ubuntu:16.04

# Copy required scripts and files, and set the working directory
WORKDIR /tmp/cf-install/
COPY install/silent.properties install/setup-ubuntu-dependencies.sh install/setup-ubuntu-pdf-dependencies.sh /tmp/cf-install/

# Setup platform and PDF dependencies
RUN chmod +x setup-ubuntu-dependencies.sh; \
        sleep 1; \
        ./setup-ubuntu-dependencies.sh \
	sleep 1; \
	chmod +x setup-ubuntu-pdf-dependencies.sh; \
        sleep 1; \
        ./setup-ubuntu-pdf-dependencies.sh;

ARG installerPath

# Create user, and install ColdFusion Addons. Sleep for a second after chmod, to ensure execution occurs seamlessly
RUN useradd --system --no-create-home -r cfuser; \
        wget --no-check-certificate $installerPath;  \
        sleep 1; \
        chmod +x ColdFusion_2016_Addon_linux64.bin;  \
        sleep 1; \
        service_username=cfuser;  \
        sleep 1;  \
        ./ColdFusion_2016_Addon_linux64.bin -f silent.properties -i silent -DSILENT_RUNTIME_USER=$service_username;  \
        rm -rf ColdFusion_2016_Addon_linux64.bin; 

# Copy hotfix updated files into installed location 
COPY install/updateFiles/ /opt/coldfusionaddonservices/

# Expose ports 8989 (jetty) from the container to the host
EXPOSE 8989

HEALTHCHECK --interval=1m --timeout=10s \
        CMD curl -f http://localhost:8989/solr/ || exit 1

# Set labels for identifications
LABEL   product="2016" \
        update="5" \
        platform="Linux" \
	type="addons" \
        description="Addons for Adobe ColdFusion 2016" \
        version="1.0"

# Update working directory
WORKDIR /opt

# Remove apt caches and temp files. Create required directories
RUN rm -rf /var/lib/apt/lists/* && \
        rm -rf /tmp/cf-install && \
        mkdir /opt/startup

# Command to execute once the container has been created
COPY startup/start-jetty.sh /opt/startup

ENTRYPOINT ["sh", "/opt/startup/start-jetty.sh"]
CMD ["start"]
