FROM httpd:2.4.27

# Install CURL for healthcheck
RUN apt-get --assume-yes update && \
        apt-get --assume-yes install -y --no-install-recommends \
        curl

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY mod_jk.conf /usr/local/apache2/conf/mod_jk.conf
COPY 1/ /opt/coldfusion/config/wsconfig/1

