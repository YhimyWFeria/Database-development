SELECT table_schema "TABLE_SHEMA", 
Round(Sum(data_length + index_length) / 1024 / 1024, 1) Size_in_MB,
Round(Sum(data_length + index_length) / 1024 / 1024 / 1024, 1) Size_in_GB,
Round(Sum(data_length + index_length) / 1024 / 1024 / 1024 / 1024, 1) Size_in_TB
FROM   information_schema.tables 
GROUP  BY table_schema
ORDER BY `DB Size in MB` DESC;