<cfscript>
	try
	{
		login= createObject("component","CFIDE.adminapi.administrator").login(<ADMIN_PASSWORD>);
		runtimecfc=createObject("component", "CFIDE.adminapi.runtime");
	
		runtimecfc.setruntimeProperty('sessionStorage','redis');
		runtimecfc.setruntimeProperty('sessionStorageHost', <REDIS_HOST>); 
		runtimecfc.setRuntimeProperty('sessionStoragePort', <REDIS_PORT>);
		runtimecfc.setRuntimeProperty('sessionStoragePassword', <REDIS_PASSWORD>);

		writeoutput("External Session Storage: "  & runtimecfc.getRuntimeProperty('sessionStorage'));
	}
	catch(Any any)
	{
		WriteOutput("External Session Storage: " & any.message);
	}
</cfscript>
