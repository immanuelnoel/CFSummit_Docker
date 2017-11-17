<cfscript>

	try
        {
                login= createObject("component","CFIDE.adminapi.administrator").login(<ADMIN_PASSWORD>);
		
		security = createObject("component", "CFIDE.adminapi.security");
        	security.enableSecureProfile();
                
		writeoutput("Secure Profile Enabled: " & security.isSecureProfile());
        }
        catch(Any any)
        {
                WriteOutput("Secure Profile: " & any.message);
        }

</cfscript>

