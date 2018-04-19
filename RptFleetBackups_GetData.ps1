. .\RptFleetBackups_CFG.ps1

cd $WorkingDirectory

. D:\vmmc\bin\PowerShell\mssql_scripts\Shared\ProfileGlobal.ps1



#Prep the Tables
invoke-sqlcmd -ServerInstance mssqldba-ym -Database VM_DBA_Reports -Query "truncate table RptFleetBackups_Work"
invoke-sqlcmd -ServerInstance mssqldba-ym -Database VM_DBA_Reports -Query "truncate table RptFleetBackups_InstanceDatabases"


Function Get-Data
{
foreach ($Instance in ..\Lib\Get-InstancesProd.ps1 ) {

    if ([String]::IsNullOrWhiteSpace($Instance)) {continue}

    $Instance

    $LoadFile="RptFleetBackups_InstanceDatabases.csv"
    $DestinationTable = "RptFleetBackups_InstanceDatabases"

    invoke-sqlcmd -ServerInstance $Instance -Database msdb -InputFile RptFleetBackups_InstanceDatabases.sql | export-csv -Path $LoadFile

    $ConnectionString = "Data Source=$Global:InventoryServer; Database=VM_DBA_Reports; Trusted_Connection=True;";
    $csvDataTable = Import-CSV -Path $LoadFile | Out-DbaDataTable 
    $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $ConnectionString 
    $bulkCopy.DestinationTableName = $DestinationTable
    $bulkCopy.WriteToServer($csvDataTable)
    
    $LoadFile="RptFleetBackups.csv"
    $DestinationTable = "RptFleetBackups_Work"

    invoke-sqlcmd -ServerInstance $Instance -Database msdb -InputFile RptFleetBackups.sql | export-csv -Path $LoadFile

    $ConnectionString = "Data Source=$Global:InventoryServer; Database=VM_DBA_Reports; Trusted_Connection=True;";
    $csvDataTable = Import-CSV -Path $LoadFile | Out-DbaDataTable 
    $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $ConnectionString 
    $bulkCopy.DestinationTableName = $DestinationTable

    
    $bulkCopy.WriteToServer($csvDataTable)
    
 }
 }


 Function Get-Data-2000 {

 #Now get 2000 instances

foreach ($Instance in ..\Lib\Get-InstancesProd_2000.ps1  ) {

    if ([String]::IsNullOrWhiteSpace($Instance)) {continue}

    $Instance

    $LoadFile="RptFleetBackups_InstanceDatabases.csv"
    $DestinationTable = "RptFleetBackups_InstanceDatabases"

    
    invoke-sqlcmd -ServerInstance $Instance -Database msdb -InputFile RptFleetBackups_InstanceDatabases_2000.sql | export-csv -Path $LoadFile


    write-host "Writing to table $DestinationTable"

    $ConnectionString = "Data Source=$Global:InventoryServer; Database=VM_DBA_Reports; Trusted_Connection=True;";
    $csvDataTable = Import-CSV -Path $LoadFile | Out-DbaDataTable 
    $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $ConnectionString 
    $bulkCopy.DestinationTableName = $DestinationTable
    $bulkCopy.WriteToServer($csvDataTable)
    
    $LoadFile="RptFleetBackups.csv"
    $DestinationTable = "RptFleetBackups_Work"

    invoke-sqlcmd -ServerInstance $Instance -Database msdb -InputFile RptFleetBackups_2000.sql | export-csv -Path $LoadFile

    write-host "Writing to table $DestinationTable"

    $ConnectionString = "Data Source=$Global:InventoryServer; Database=VM_DBA_Reports; Trusted_Connection=True;";
    $csvDataTable = Import-CSV -Path $LoadFile | Out-DbaDataTable 
    $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $ConnectionString 
    $bulkCopy.DestinationTableName = $DestinationTable

    
    $bulkCopy.WriteToServer($csvDataTable)
    
 }
 }

 Get-Data-2000
 Get-Data



 invoke-sqlcmd -ServerInstance mssqldba-ym -Database VM_DBA_Reports -InputFile RptFleetBackups_Work_Rebuild_indexes.sql 


 invoke-sqlcmd -ServerInstance mssqldba-ym -Database VM_DBA_Reports -query "update TablesLastUpdated set LastUpdated = getdate() where tablename in ('RptFleetBackups_InstanceDatabases','RptFleetBackups_Work')"
 
 


