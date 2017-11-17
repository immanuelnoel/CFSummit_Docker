#!/bin/bash

# METHODS

# Start ColdFusion in the foreground
start()
{
	if [ -e /opt/startup/disableScripts ]; then

                echo "Skipping Addon Service setup"
                return
        else

		setupDatastore

		setupAnalyticsServer

		touch /opt/startup/disableScripts

		tail -f /opt/coldfusionAPIManagerAddons/datastore/redis.log -f /opt/coldfusionAPIManagerAddons/analytics/logs/*.log 

	fi	
}

setupDatastore(){

	if [ -z ${startDatastoreService+x} ]; then
                echo "Datastore: Disabled"
        else
                if [ $startDatastoreService = true ]; then

			echo "Configuring Datastore"

			# Update Redis Persistance directory. This could be mapped to a volume to ensure persistence when container is destroyed
			echo "Updating Redis data directory to /data/datastore. This directory can be volume mounted to ensure data persistence"
			if [ ! -d /data/datastore ]; then
				# Create /data/datastore if not already volume mounted
				mkdir -p /data/datastore
        		fi
			chown -R apimuser /data/datastore	
			sed -i -- 's_dir ./_dir /data/datastore_g' /opt/coldfusionAPIManagerAddons/datastore/redis.conf.properties

			# Comment bind 127.0.0.1 in redis.conf.properties
			echo "Listening for connections for all hosts. Control access for container ports"
			sed -i -- 's/bind 127.0.0.1/# bind 127.0.0.1/g' /opt/coldfusionAPIManagerAddons/datastore/redis.conf.properties		

			# Setup Redis Password
                        if [ -z ${datastorePassword+x} ]; then
                                # Defaults
                                datastorePassword=""
			fi
			# Update string starting with "requirepass" in redis.conf.properties
			echo "Updating the Datastore, Redis Password to $datastorePassword"
			sed -i -- 's/requirepass\s[a-zA-Z0-9]*/requirepass '$datastorePassword'/g' /opt/coldfusionAPIManagerAddons/datastore/redis.conf.properties

			# Setup init scripts
        		/opt/coldfusionAPIManagerAddons/datastore/apimdatastore start
	
			# Start server
			/opt/coldfusionAPIManagerAddons/datastore/apimdatastore start
		
		else
			echo "Datastore: Disabled"
		fi
	fi
}

setupAnalyticsServer(){

	if [ -z ${startAnalyticsService+x} ]; then
                echo "Analytics Service: Disabled"
        else
                if [ $startAnalyticsService = true ]; then

			echo "Configuring Analytics Server"

			# Update ElasticSearch Persistance directory. This could be mapped to a volume to ensure persistence when container is destroyed
                        echo "Updating ElasticSearch data directory to /data/analytics. This directory can be volume mounted to ensure data persistence"
                        if [ ! -d /data/analytics ]; then
                                # Create /data/analytics if not already volume mounted
                                mkdir -p /data/analytics
                        fi
                        chown -R apimuser /data/analytics
			sed -i -- 's_#path.data: /path/to/data1,/path/to/data2_#path.data: /path/to/multiple/comma/seperated/paths_g' /opt/coldfusionAPIManagerAddons/analytics/config/elasticsearch.yml
                        sed -i -- 's_#path.data: /path/to/data_path.data: /data/analytics_g' /opt/coldfusionAPIManagerAddons/analytics/config/elasticsearch.yml

			# Comment local.bind to accept connections from all machines
			echo "Listening for connections for all hosts. Control access for container ports"
                        sed -i -- 's/network.host: 127.0.0.1/# network.host: 127.0.0.1/g' /opt/coldfusionAPIManagerAddons/analytics/config/elasticsearch.yml 

			# Setup analyticsClusterName
			if [ -z ${analyticsClusterName+x} ]; then
				# Defaults
	        		analyticsClusterName="groot-elasticsearch"
			fi
			# Update 'cluster.name: groot-elasticsearch' in config/elasticsearch.yml
			echo "Updating the Analytics Server, ElasticSearch ClusterName to $analyticsClusterName"
			sed -i -- 's/cluster.name: groot-elasticsearch/cluster.name: '$analyticsClusterName'/g' /opt/coldfusionAPIManagerAddons/analytics/config/elasticsearch.yml

                	# Setup init scripts
        		/opt/coldfusionAPIManagerAddons/analytics/bin/apimanalytics start

        		# Start server
        		/opt/coldfusionAPIManagerAddons/analytics/bin/apimanalytics start
		
		else
			echo "Analytics Service: Disabled"
		fi
        fi
}

help(){
        echo "Supported commands: help, start <.cfm>"
	echo "Optional ENV Variables:
		startDatastoreService=<true/false>
		startAnalyticsService=<true/false>
		datastorePassword=<Redis Password>
		analyticsClusterName=<Elastic Search Cluster Name>"
}

# METHODS END

case "$1" in
        "start")
                start
                ;;

        help)
                help
                ;;

        *)
                cd /opt/coldfusionAPIManagerAddons/
                exec "$@"
                ;;

esac

