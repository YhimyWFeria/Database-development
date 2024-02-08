
SET NOCOUNT ON;
DECLARE @iurldisk varchar(600);
DECLARE @sqlcmdexecute NVARCHAR(max)
 
-- Ingresar ruta devices
SET  @iurldisk = '\\POCCLUSTER1\Devicesbackup';
SET @sqlcmdexecute ='';
IF (right(@iurldisk, 1)<>'\') SET @iurldisk = @iurldisk +'\';
 
SELECT  @sqlcmdexecute = @sqlcmdexecute + 'IF NOT EXISTS (SELECT * FROM master.sys.backup_devices where name = N''demo_bkp_' + name + ''')
BEGIN
	
	EXEC master.dbo.sp_addumpdevice  @devtype = N''disk'', @logicalname = N''demo_bkp_' + name + ''', @physicalname = N''' + @iurldisk + 'demo_bkp_db_' + name + '.bak''
END
'
FROM sys.databases
WHERE name not in ('model', 'tempdb') and state=0 and is_read_only=0
 
EXECUTE sp_executesql @statement = @sqlcmdexecute

 