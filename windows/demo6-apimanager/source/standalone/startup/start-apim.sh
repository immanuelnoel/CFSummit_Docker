#!/bin/bash

# METHODS

# Start APIManager in the foreground
start() 
{
	if [ -e /opt/startup/disableScripts ]; then

                echo "Skipping Addon Service setup"
                return
        else

		updateAPIMSettings

		updateDatastoreSettings

		updateAnalyticsServerSettings

		/opt/coldfusionapimanager/bin/apimanager start
        
		touch /opt/startup/disableScripts
	
		tail -f /opt/coldfusionapimanager/logs/apimanager-out.log
	fi
}

updateAPIMSettings(){

	# Update APIM Password 
        if [ -z ${apimPassword+x} ]; then
        	# Defaults
                apimPassword="admin"
	fi
        echo "Updating API Manager password to $apimPassword"
	sed -i -- 's/adminpassword=null/adminpassword='$apimPassword'/g' /opt/coldfusionapimanager/conf/password.properties
}

updateDatastoreSettings(){

	# Update Datastore Hostname
        if [ -z ${datastoreHost+x} ]; then
                # Defaults
                datastoreHost="127.0.0.1"
        fi
	echo "Updating the Datastore Hostname to $datastoreHost"
	xmlstarlet ed -P -S -L --inplace -u '/root/redis/client/host' -v $datastoreHost /opt/coldfusionapimanager/conf/config.xml

	# Update Datastore Port
        if [ -z ${datastorePort+x} ]; then
                # Defaults
                datastorePort=6379
        fi
	echo "Updating the Datastore Port to $datastorePort"
	xmlstarlet ed -P -S -L --inplace -u '/root/redis/client/port' -v $datastorePort /opt/coldfusionapimanager/conf/config.xml

	# Update Redis Password
        if [ -z ${datastorePassword+x} ]; then
                # Defaults
                datastorePassword=""
        fi
	echo "Updating the Datastore, Redis Password to $datastorePassword"
	xmlstarlet ed -P -S -L --inplace -u '/root/redis/client/password' -v $datastorePassword /opt/coldfusionapimanager/conf/config.xml
}

updateAnalyticsServerSettings(){

	# Update Analytics Server Hostname
        if [ -z ${analyticsHost+x} ]; then
                # Defaults
                analyticsHost="127.0.0.1"
        fi
	echo "Updating the Analytics Server Hostname to $analyticsHost"
	xmlstarlet ed -P -S -L --inplace -u '/defaultSetting/elastic/remoteServers/server/host' -v $analyticsHost /opt/coldfusionapimanager/conf/default_conf.xml

	# Update Analytics Server Port
        if [ -z ${analyticsPort+x} ]; then
                # Defaults
                analyticsPort=9200
	fi	        
	echo "Updating the Analytics Server Port to $analyticsPort"
	xmlstarlet ed -P -S -L --inplace -u '/defaultSetting/elastic/remoteServers/server/httpport' -v $analyticsPort /opt/coldfusionapimanager/conf/default_conf.xml

	# Update Analytics Server Cluster Port
        if [ -z ${analyticsClusterPort+x} ]; then
                # Defaults
                analyticsClusterPort=9300
        fi
        echo "Updating the Analytics Server Cluster Port to $analyticsClusterPort"
        xmlstarlet ed -P -S -L --inplace -u '/defaultSetting/elastic/remoteServers/server/clusterport' -v $analyticsClusterPort/opt/coldfusionapimanager/conf/default_conf.xml

	# Update ElasticSearch cluster name
        if [ -z ${analyticsClusterName+x} ]; then
                # Defaults
                analyticsClusterName="groot-elasticsearch"
        fi
	echo "Updating the Analytics Server, ElasticSearch cluster name to $analyticsClusterName"
	xmlstarlet ed -P -S -L --inplace -u '/defaultSetting/elastic/clusterName' -v $analyticsClusterName /opt/coldfusionapimanager/conf/default_conf.xml
}

info(){
        /opt/coldfusionapimanager/bin/apimanagerinfo.sh -version
}

help(){

	echo "Supported commands: help, start <.cfm>"
        echo "Optional ENV Variables:
                apimPassword=<API Manager Admin Password>
                datastoreHost=<Datastore Hostname>
                datastorePort=<Datastore Port>
		datastorePassword=<Redis (Datastore) Password>
                analyticsHost=<Analytics Server Hostname>
		analyticsPort=<Analytics Server Port>
		analyticsClusterPort=<Analytics Server Cluster Port>
		analyticsClusterName=<ElasticSearch Cluster Name>"
}

# METHODS END

case "$1" in
	"start") 
		start 
		;;

	info) 
		info
		;; 
	
	help)
		help
		;;
		
	*) 	
		cd /opt/coldfusionapimanager/bin/
		exec "$@" 
		;;
		
esac

