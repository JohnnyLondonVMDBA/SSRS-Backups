select @@servername,name,databasepropertyex(name,'Recovery') as recovery_model_desc from master.dbo.sysdatabases where name not like '%TempDB%'and name not like '%tempdb%' and databasepropertyex(name,'Status') = 'ONLINE'