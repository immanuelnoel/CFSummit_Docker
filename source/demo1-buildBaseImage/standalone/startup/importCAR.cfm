<cfscript>

        factory = createObject("java", "coldfusion.server.ServiceFactory");
        deployCARObj = factory.getArchiveDeployService();
        deployCARObj.setWorkingDirectory("/opt/coldfusion/cfusion/runtime/conf/Catalina/localhost/tmp/");

        archiveList =  DirectoryList("/data",false,"path","*.car");

        for(i = 1; i <= ArrayLen(archiveList); i++){
                writeOutput("Importing " & archiveList[i]);
                archiveObj = deployCARObj.retrieveArchive(archiveList[i]);
                archiveObj.deploy(true);
        }

</cfscript>

