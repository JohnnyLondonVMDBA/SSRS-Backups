select 
@@SERVERNAME,
database_name as DatabaseName
,case bs.type
when 'L' then 'Log'
when 'D' then 'Full'
when 'I' then 'Incr'
end as BackupType
,bs.backup_size as SizeBytes
,cast(bs.backup_size/1048576 as numeric(8,1)) as sizeMB
,bs.compressed_backup_size as CompressedSizeBytes
,cast(bs.compressed_backup_size/1048576 as numeric(8,1)) as CompressedSizeMB
,bs.backup_start_date as BackupStarted
,bs.backup_finish_date as BackupCompleted
,datediff(ss,bs.backup_start_date,bs.backup_finish_date) Seconds
,datediff(ss,bs.backup_start_date,bs.backup_finish_date)/60 Minutes
,bs.first_lsn as FirstLSN
,bs.last_lsn as LastLSN
,bmf.physical_device_name as BackupPath
from msdb.dbo.backupset bs
inner join msdb.dbo.backupmediafamily as bmf on bmf.media_set_id = bs.media_set_id
where bs.backup_finish_date > DATEADD (hour,-72,getdate())


