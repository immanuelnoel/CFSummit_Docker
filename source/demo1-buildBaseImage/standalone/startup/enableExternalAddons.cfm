<cfscript>
        try
        {
                login= createObject("component","CFIDE.adminapi.administrator").login(<ADMIN_PASSWORD>);

		// PDF Service Configuration
                serviceObj = createObject("component", "CFIDE.adminapi.document");

                try {
                        // Remove remote container if already exists
                        serviceObj.removeServiceManager(<PDF_SERVICE_NAME>);

                        // Disable local connections
                        serviceObj.disableServiceManager("localhost");

                } catch(Any e) { writeOutput(e.message);  }

                serviceObj.addServiceManager(<PDF_SERVICE_NAME>,<ADDONS_HOST>, <ADDONS_PORT>, 2, <PDF_SSL>);
                serviceObj.verifyServiceManager(<PDF_SERVICE_NAME>);
                serviceObj.enableServiceManager(<PDF_SERVICE_NAME>);
                writeOutput("Service Manager for ColdFusion Addons container added.");

        	// END PDF Service Configuration

		// SOLR Service Configuration

		factory = createObject("java", "coldfusion.server.ServiceFactory"); 
		solrObj = factory.getSolrService();
		solrObj.setSolrHost(<ADDONS_HOST>);
		solrObj.setSolrPort(<ADDONS_PORT>);
		solrObj.setUsername(<ADDONS_USERNAME>);
		solrObj.setPassword(<ADDONS_PASSWORD>);
		writeOutput("Solr configurations complete");

		// END SOLR Service Configuration
	}
        catch(Any any)
        {
                writeOutput("External Addon Server Configuration: " & any.message);
        }
</cfscript>

