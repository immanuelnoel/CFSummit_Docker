#!/bin/bash

# METHODS

# Start ColdFusion in the foreground
start()
{
	 if [ -e /opt/startup/disableScripts ]; then

                echo "Skipping Addon Service setup"
                return
	else 

		# Update hostname to 0.0.0.0 : Accept connections from everywhere! Restrictions are placed in the docker environment instead
		echo "Updating connector host to 0.0.0.0"
		xmlstarlet ed -P -S -L --inplace -u '/Configure/Call[@name="addConnector"]/Arg/New/Set[@name="host"]/Property[@name="jetty.http.host"]/@default' -v 0.0.0.0 /opt/coldfusionaddonservices/etc/jetty.xml

		# Provide appropriate permissions for files updated on hotfix installation
		echo "Executing hotfix updates"
		chmod -R +x /opt/coldfusionaddonservices/webapps/PDFgServlet/Resources/bin

		# Provide ownership of the entire directory to cfuser
		echo "Updating ownerships"
		chown -R cfuser /opt/coldfusionaddonservices/

		/opt/coldfusionaddonservices/cfjetty start
	
		touch /opt/startup/disableScripts

		tail -f /opt/coldfusionaddonservices/logs/start.log
	fi
}

help(){
        echo "Supported commands: help, start <.cfm>"
	echo "Optional ENV Variables:
		solrUsername=<SOLR-USERNAME>
		solrPassword=<SOLR-PASSWORD>"
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
                cd /opt/coldfusionaddonservices/
                exec "$@"
                ;;

esac

