# CFSummit2017: Containerization with ColdFusion #

Demo content from the CFSummit 2017 session, Containerization with ColdFusion    
Includes source to build images in demo1 (ColdFusion), and demo6 (API Manager)

### Usage ###

* source/commands.txt lists down all commands used during the demo
* As a best practice, images are built on Linux, and are used in Windows / Linux
* commands.txt includes comments to indicate the difference in usage on Linux
* The wwwroot/ directory could be placed at /opt/wwwroot, or C:/wwwroot, for the scripts to work as-is

### About the ColdFusion image ###    
        
* Built on Ubuntu 16.04 
* Barebones. Has the latest update applied on a standalone installation. Does not contain, Jetty, Solr, PDF   
* Installation location: /opt/coldfusion
* Webroot: Redefined to, /app   
* CAR archives present in /data will be automatically imported
* /CFIDE, /cf_scripts, /WEB-INF are virtual directories on Tomcat. Available on 8500. Unavailable when configured with the connector
* Environment variables:
		-e password=Admn1$                              // Updates Password    
		-e enableSecureProfile=true                     // Enables secure Profile         
		-e configureExternalSessions=true               // Setup external storage        
		-e externalSessionsHost=<REDIS HOST NAME>       // Specify Redis Host. Defaults to localhost       
		-e externalSessionsPort=<REDIS PORT>            // Specify Redis Port. Defaults to 6379          
		-e externalSessionsPassword=<REDIS PASSWORD>    // Specify Redis Password. Defaults to empty.             
		-e setupScript=<CFM present in /app>            // Executes the CFM script on ColdFusion startup, and deletes it once a response is received.      
* <IMPORTANT> Before going live, mount the latest JRE to /opt/coldfusion/jre. This is required due to a security loophole  

### Disclaimer ###
This is a work in progress. Make informed choices / customization.     
