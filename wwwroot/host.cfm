<cfset inet = CreateObject("java", "java.net.InetAddress")>
<cfset inet = inet.getLocalHost()>
Hostname: <cfoutput>#inet.getHostName()#</cfoutput></br>

<cfscript>

        // Login is always required. This example uses two lines of code.
        adminObj = createObject("component","CFIDE.adminapi.administrator");
        adminObj.login("ColdFusion123"); //CF Admin password

        runtimecfc=createObject("component", "CFIDE.adminapi.runtime");
        prop = runtimecfc.getruntimeProperty('sessionStorage');
        writeOutput("Session Storage: " & prop & "</br>");
</cfscript>

<cfoutput>Product Version: #SERVER.ColdFusion.ProductVersion#</cfoutput>
