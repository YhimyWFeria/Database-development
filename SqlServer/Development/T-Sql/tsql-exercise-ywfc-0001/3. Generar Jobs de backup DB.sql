
SET NOCOUNT ON;
DECLARE @sqlcmdexecute NVARCHAR(max);

DECLARE @tb_list_databases TABLE (Id int identity (1,1) PRIMARY KEY ,name varchar(100), create_date datetime)

INSERT INTO @tb_list_databases (name,create_date )
SELECT  name, create_date  FROM sys.databases where name not in ('model', 'tempdb') and state=0 and is_read_only=0 and is_distributor  =0;

-- Variables de operaci�n.
DECLARE @p_dbname varchar(100), @p_crdate datetime, @v_while_total int ,@v_while_count int;

-- Iniciar Varirables
SET @p_dbname = ''; SET @p_crdate = GETDATE(); SET @v_while_total = 0 ; SET @v_while_count = 0;
Select @v_while_total = count(1) from @tb_list_databases

WHILE (@v_while_total>@v_while_count)
BEGIN
		 SET @v_while_count +=1;
		 SELECT   @p_dbname=name, @p_crdate=create_date  FROM @tb_list_databases WHERE Id = @v_while_count;

		 IF NOT EXISTS  (select * from msdb..sysjobs where name='citizen_mnt_Backup_' + @p_dbname)
		 BEGIN

			  SET @sqlcmdexecute = '		print '''+@p_dbname+'''
					
											DECLARE @jobId BINARY(16)
											EXEC  msdb.dbo.sp_add_job @job_name=N''citizen_mnt_Backup_' + @p_dbname + ''', 
													@enabled=1, 
													@notify_level_eventlog=0, 
													@notify_level_email=2, 
													@notify_level_netsend=0, 
													@notify_level_page=0, 
													@delete_level=0, 
													@description=N''Generacion de Backup de la BD ' + @p_dbname + ''', 
													@category_name=N''Database Maintenance Backup'', 
													@owner_login_name=N''sa'', @job_id = @jobId OUTPUT

													EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Backup'', 
													@step_id=1, 
													@cmdexec_success_code=0, 
													@on_success_action=1, 
													@on_success_step_id=0, 
													@on_fail_action=2, 
													@on_fail_step_id=0, 
													@retry_attempts=1, 
													@retry_interval=1, 
													@os_run_priority=0, @subsystem=N''TSQL'', 
													@command=N''BACKUP DATABASE [' + @p_dbname + '] TO [citizen_bkp_' + @p_dbname + '] WITH INIT, FORMAT, CHECKSUM
													declare @backupSetId as int  
													select @backupSetId = position from msdb..backupset where database_name=N''''' + @p_dbname + ''''' and 
													backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''''' + @p_dbname + ''''' ) 
													if @backupSetId is null 
													begin
													raiserror(N''''Verify failed. Backup information for database ''''''''' + @p_dbname + ''''''''' not found.'''', 16, 1) 
													end
													RESTORE VERIFYONLY FROM  [citizen_bkp_' + @p_dbname + '] WITH  FILE = @backupSetId, CHECKSUM'', 
													@database_name=N''' + @p_dbname + ''', 
													@flags=4

													EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
													 
													EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''sch_mnt_Backup_' + @p_dbname + ''', 
													@enabled=1, 
													@freq_type=4, 
													@freq_interval=1, 
													@freq_subday_type=1, 
													@freq_subday_interval=0, 
													@freq_relative_interval=0, 
													@freq_recurrence_factor=0, 
													@active_start_date=20070222, 
													@active_end_date=99991231, 
													@active_start_time=3000, 
													@active_end_time=235959

													EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)'';
													
			  ';
			--  PRINT @sqlcmdexecute
			  EXECUTE sp_executesql @statement = @sqlcmdexecute
		 END
END

