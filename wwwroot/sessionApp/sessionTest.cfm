<cfif structKeyExists(session, "MyCount") eq false>
	<cfset SESSION.MyCount = 1>
	<cfset SESSION.StartTime = Now()>	
<cfelse>
	<cfset SESSION.MyCount = #SESSION.MyCount# + 1>
</cfif>

<cfset inet = CreateObject("java", "java.net.InetAddress")>
<cfset inet = inet.getLocalHost()>

Host: <cfoutput>#inet.getHostName()#</cfoutput>
Current Count is: <cfoutput>#SESSION.MyCount#</cfoutput><BR>
The current time is <cfoutput>#Now()#</cfoutput> and the Session Started at:  <cfoutput>#SESSION.StartTime#</cfoutput><BR>
<A HREF="sessionTest.cfm">Test Session</A>
