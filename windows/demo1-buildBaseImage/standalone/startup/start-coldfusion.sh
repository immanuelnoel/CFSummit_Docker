#!/bin/bash

# METHODS

# CLI filename. Empty if not specified
filename=$2

# Start ColdFusion in the foreground
start()
{
	if [ -e /opt/startup/disableScripts ]; then
		
		echo "Skipping ColdFusion setup"
		startColdFusion 0
				
	else
		updateWebroot
        
		updatePassword

		startColdFusion 0

        	importCAR
		restartRequired=$?

		setupExternalAddons
		if [ "$restartRequired" != 1 ]; then
                        restartRequired=$?
                fi

                setupExternalSessions
                if [ "$restartRequired" != 1 ]; then
                        restartRequired=$?
                fi

        	invokeCustomCFM
        	if [ "$restartRequired" != 1 ]; then
                	restartRequired=$?
        	fi

		# Secure profile enablement goes last. This is to faciliate the scripts to execute SecureProfile disabled sections
		enableSecureProfile
                if [ "$restartRequired" != 1 ]; then
                        restartRequired=$?
                fi

		cleanupTestDirectories
        	if [ "$restartRequired" = 1 ]; then
                	startColdFusion 1
        	fi

		echo 'Do not delete. Avoids script execution on container start' >  /opt/startup/disableScripts        
	fi

	# Listen to start a daemon
	tail -f /opt/coldfusion/cfusion/logs/coldfusion-out.log
}

startColdFusion(){

        # Stop ColdFusion if $1 = 1
        if [ "$1" = 1 ]; then
		echo "Restarting ColdFusion"
                /opt/coldfusion/cfusion/bin/coldfusion stop
	else
		echo "Starting ColdFusion"
        fi

        # Start ColdFusion Service
        /opt/coldfusion/cfusion/bin/coldfusion start

        # Wait for ColdFusion startup before returning control
        sleep 10 
}

updateWebroot(){

        echo "Updating webroot to /app"
        xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host -t elem -n ContextHolder -v "" \
                -i //ContextHolder -t attr -n "path" -v "" \
                -i //ContextHolder -t attr -n "docBase" -v "/app" \
                -i //ContextHolder -t attr -n "WorkDir" -v "/opt/coldfusion/cfusion/runtime/conf/Catalina/localhost/tmp" \
                -r //ContextHolder -v Context \
        /opt/coldfusion/cfusion/runtime/conf/server.xml

        echo "Configuring virtual directories"
        xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host/Context -t elem -n ResourceHolder -v "" \
                -r //ResourceHolder -v Resources \
        /opt/coldfusion/cfusion/runtime/conf/server.xml

        xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host/Context/Resources -t elem -n PreResourcesHolder -v "" \
                -i //PreResourcesHolder -t attr -n "base" -v "/opt/coldfusion/cfusion/wwwroot/CFIDE" \
                -i //PreResourcesHolder -t attr -n "className" -v "org.apache.catalina.webresources.DirResourceSet" \
                -i //PreResourcesHolder -t attr -n "webAppMount" -v "/CFIDE" \
                -r //PreResourcesHolder -v PreResources \
        /opt/coldfusion/cfusion/runtime/conf/server.xml

	xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host/Context/Resources -t elem -n PreResourcesHolder -v "" \
                -i //PreResourcesHolder -t attr -n "base" -v "/opt/coldfusion/cfusion/wwwroot/cf_scripts" \
                -i //PreResourcesHolder -t attr -n "className" -v "org.apache.catalina.webresources.DirResourceSet" \
                -i //PreResourcesHolder -t attr -n "webAppMount" -v "/cf_scripts" \
                -r //PreResourcesHolder -v PreResources \
        /opt/coldfusion/cfusion/runtime/conf/server.xml

	xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host/Context/Resources -t elem -n PreResourcesHolder -v "" \
                -i //PreResourcesHolder -t attr -n "base" -v "/opt/coldfusion/cfusion/wwwroot/WEB-INF" \
                -i //PreResourcesHolder -t attr -n "className" -v "org.apache.catalina.webresources.DirResourceSet" \
                -i //PreResourcesHolder -t attr -n "webAppMount" -v "/WEB-INF" \
                -r //PreResourcesHolder -v PreResources \
        /opt/coldfusion/cfusion/runtime/conf/server.xml
	
	# Virtual directory for interal Admin APIs
	xmlstarlet ed -P -S -L -s /Server/Service/Engine/Host/Context/Resources -t elem -n PreResourcesHolder -v "" \
		-i //PreResourcesHolder -t attr -n "base" -v "/opt/startup/coldfusion/" \
                -i //PreResourcesHolder -t attr -n "className" -v "org.apache.catalina.webresources.DirResourceSet" \
                -i //PreResourcesHolder -t attr -n "webAppMount" -v "/ColdFusionDockerStartupScripts" \
                -r //PreResourcesHolder -v PreResources \
        /opt/coldfusion/cfusion/runtime/conf/server.xml

        # Copy files to webroot
        if [ ! -d /app ]; then
		mkdir /app
        fi	

	cp -R /opt/coldfusion/cfusion/wwwroot/crossdomain.xml /app/
        chown -R cfuser /app

}

cleanupTestDirectories(){

	echo "Cleaning up setup directories"
	
	# Remove virtual directory mapping from server.xml
	xmlstarlet ed -P -S -L -d '/Server/Service/Engine/Host/Context/Resources/PreResources[@webAppMount="/ColdFusionDockerStartupScripts"]' /opt/coldfusion/cfusion/runtime/conf/server.xml

	# Delete directory
	rm -rf /opt/startup/coldfusion
}

updatePassword(){

        if [ -z ${password+x} ]; then
                echo "Skipping password updation";
        else
                echo "Updating password";
                awk -F"=" '/password=/{$2="='$password'";print;next}1' /opt/coldfusion/cfusion/lib/password.properties > /opt/coldfusion/cfusion/lib/password.properties.tmp
                mv /opt/coldfusion/cfusion/lib/password.properties.tmp /opt/coldfusion/cfusion/lib/password.properties
                awk -F"=" '/encrypted=/{$2="=false";print;next}1' /opt/coldfusion/cfusion/lib/password.properties > /opt/coldfusion/cfusion/lib/password.properties.tmp
                mv /opt/coldfusion/cfusion/lib/password.properties.tmp /opt/coldfusion/cfusion/lib/password.properties

                chown cfuser /opt/coldfusion/cfusion/lib/password.properties
        fi
}

enableSecureProfile(){

        returnVal=0
        if [ -z ${enableSecureProfile+x} ]; then
                echo "Secure Profile: Disabled"
        else
                if [ $enableSecureProfile = true ]; then

			echo "Attempting to enable secure profile"

                        # Update Password
                        if [ -z ${password+x} ]; then
                                sed -i -- 's/<ADMIN_PASSWORD>/"admin"/g' /opt/startup/coldfusion/enableSecureProfile.cfm
                        else
                                sed -i -- 's/<ADMIN_PASSWORD>/"'$password'"/g' /opt/startup/coldfusion/enableSecureProfile.cfm
                        fi
 
                        curl -I "http://localhost:8500/ColdFusionDockerStartupScripts/enableSecureProfile.cfm"

                        echo "Secure Profile: Enabled"
                        returnVal=1
                else
                        echo "Secure Profile: Disabled"
                fi
        fi

        return "$returnVal"
}

setupExternalAddons(){

	returnVal=0
        if [ -z ${configureExternalAddons+x} ]; then
                echo "External Addons: Disabled"
        else
                if [ $configureExternalAddons = true ]; then

                        # Update Password
                        if [ -z ${password+x} ]; then
                                sed -i -- 's/<ADMIN_PASSWORD>/"admin"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<ADMIN_PASSWORD>/"'$password'"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

			# Update Addons Host
                        if [ -z ${addonsHost+x} ]; then
                                sed -i -- 's/<ADDONS_HOST>/"localhost"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<ADDONS_HOST>/"'$addonsHost'"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi 
			
			# Update Addons Port
			if [ -z ${addonsPort+x} ]; then
                                sed -i -- 's/<ADDONS_PORT>/8989/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<ADDONS_PORT>/'$addonsPort'/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

			# Update Addons Username
			if [ -z ${addonsUsername+x} ]; then
                                sed -i -- 's/<ADDONS_USERNAME>/"admin"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<ADDONS_USERNAME>/"'$addonsUsername'"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

			# Update Addons Password
			if [ -z ${addonsPassword+x} ]; then
                                sed -i -- 's/<ADDONS_PASSWORD>/"admin"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<ADDONS_PASSWORD>/"'$addonsPassword'"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

			# Update PDF Service name
			if [ -z ${addonsPDFServiceName+x} ]; then
                                sed -i -- 's/<PDF_SERVICE_NAME>/"addonsContainer"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<PDF_SERVICE_NAME>/"'$addonsPDFServiceName'"/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

			# Update PDF SSL
			if [ -z ${addonsPDFSSL+x} ]; then
                                sed -i -- 's/<PDF_SSL>/false/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        else
                                sed -i -- 's/<PDF_SSL>/'$addonsPDFSSL'/g' /opt/startup/coldfusion/enableExternalAddons.cfm
                        fi

                        curl -I "http://localhost:8500/ColdFusionDockerStartupScripts/enableExternalAddons.cfm"

                        echo "External Addons: Enabled"
                        returnVal=1
                else
                        echo "External Addons: Disabled"
                fi
        fi

        return "$returnVal"
}

setupExternalSessions(){

	returnVal=0

        if [ -z ${configureExternalSessions+x} ]; then
                echo "External Session Storage: Disabled"
        else
		if [ $configureExternalSessions = true ]; then
	
			# Update Password
	                if [ -z ${password+x} ]; then
                		sed -i -- 's/<ADMIN_PASSWORD>/"admin"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
                	else
                		sed -i -- 's/<ADMIN_PASSWORD>/"'$password'"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
        	        fi
	
			if [ -z ${externalSessionsHost+x} ]; then
				sed -i -- 's/<REDIS_HOST>/"localhost"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
				externalSessionsHost="localhost"
			else
				sed -i -- 's/<REDIS_HOST>/"'$externalSessionsHost'"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
			fi

			if [ -z ${externalSessionsPort+x} ]; then
				sed -i -- 's/<REDIS_PORT>/"6379"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
				externalSessionsPort="6379"
                	else
        	                sed -i -- 's/<REDIS_PORT>/"'$externalSessionsPort'"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
			fi		

			if [ -z ${externalSessionsPassword+x} ]; then
				sed -i -- 's/<REDIS_PASSWORD>/""/g' /opt/startup/coldfusion/enableSessionStorage.cfm
                	else
                        	sed -i -- 's/<REDIS_PASSWORD>/"'$externalSessionsPassword'"/g' /opt/startup/coldfusion/enableSessionStorage.cfm
			fi
	
			echo "Configuring external session storage on $externalSessionsHost:$externalSessionsPort"
	
			curl -I "http://localhost:8500/ColdFusionDockerStartupScripts/enableSessionStorage.cfm"
	
			returnVal=1
		else
			echo "External Session Storage: Disabled"
		fi
	fi

	return "$returnVal"

}

importCAR(){

	stat -t -- /data/*.car >/dev/null 2>&1 && returnVal=1 || returnVal=0        

	curl "http://localhost:8500/ColdFusionDockerStartupScripts/importCAR.cfm"

	return "$returnVal"
}

invokeCustomCFM(){

        returnVal=0
        if [ -z ${setupScript+x}  ]; then
                echo "Skipping setup script invocation"
        else
                echo "Invoking custom CFM, $setupScript"
                curl -I "http://localhost:8500/$setupScript"

                returnVal=1
        fi

        return "$returnVal"
}


info(){
        /opt/coldfusion/cfusion/bin/cfinfo.sh -version
}

cli(){
	cd /app
        /opt/coldfusion/cfusion/bin/cf.sh "$filename"
}

help(){
        echo "Supported commands: help, start, info, cli <.cfm>"
	echo "Webroot: /app"
	echo "CAR imports: CAR files present in /data will be automatically imported during startup"
        echo "Optional ENV variables: 
		password=<pw>
		enableSecureProfile=<true/false(default)> 
		configureExternalSessions=<true/false(default)>
		externalSessionsHost=<Redis Host (Default:localhost)>
		externalSessionsPort=<Redis Port (Default:6379)>
		externalSessionsPassword=<Redis Password (Default:Empty)>
		configureExternalAddons=<true/false(default)>
		addonsHost=<Addon Container Host (Default: localhost)>
                addonsPort=<Addon Container Port (Default: 8989)>
		addonsUsername=<Solr username (Default: admin)>
                addonsPassword=<Solr password (Default: admin)>
		addonsPDFServiceName=<PDF Service Name (Default: addonsContainer)>
		addonsPDFSSL=<true/false(default)>
		setupScript=<CFM page to be invoked on startup. Must be present in the webroot, /app>"
}

# METHODS END

case "$1" in
        "start")
                start
                ;;

        info)
                info
                ;;

        cli)
                cli
                ;;

        help)
                help
                ;;

        *)
                cd /opt/coldfusion/cfusion/bin/
                exec "$@"
                ;;

esac

