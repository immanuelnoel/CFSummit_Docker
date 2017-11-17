<cfcomponent>
<cfset this.name = "sessionApp">
<cfset this.sessionmanagement = TRUE>
<cfset this.sessiontimeout=#CreateTimeSpan(0,0,45,0)#>
</cfcomponent>
