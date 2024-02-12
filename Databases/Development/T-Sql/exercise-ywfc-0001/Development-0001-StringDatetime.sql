 USE [MetaPhoneTask]
GO
/****** Object:  UserDefinedFunction [dbo].[SetFormatDateOfFacebookPostDatetime]    Script Date: 2/9/2024 4:53:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[SetFormatDateOfFacebookPostDatetime] (@p_time_String   varchar(100) , @p_date_include  datetime )
returns datetime
as begin
Declare @len_string int, @value1 varchar(50),@value2 varchar(50),@count_string int,@value3 varchar(10)
declare @date_sum datetime

SET @len_string =  len(@p_time_String);
SET @count_string = @len_string- len(REPLACE(@p_time_String,space(1),'')) 
	if (@len_string = 15 and  @count_string = 3)
		begin
			select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=1
			select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=4
			
			if (@value2 like '[0-2][0-9]:[0-5][0-9]')
			begin
			 
				SET @date_sum = 
							   Case
								 when @value1 ='lun' then CAST(dateadd(DD, - (1 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS date)
								 when @value1 ='mar' then CAST(dateadd(DD, - (2 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS Date)
								 when @value1 ='mie' then CAST(dateadd(DD, - (3 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS DATE)
								 when @value1 ='jue' then CAST(dateadd(DD, - (4 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS DATE)
								 when @value1 ='vie' then CAST(dateadd(DD, - (5 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS DATE)
								 when @value1 ='sáb' then CAST(dateadd(DD, - (6 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS DATE)
								 when @value1 ='dom' then CAST(dateadd(DD, - (7 - DATEPART(WEEK, @p_date_include)+ 1),@p_date_include) AS DATE)
							   End
				SET @date_sum = DATEADD(MINUTE, CAST( RIGHT(@value2,2) AS INT), DATEADD(HH,CAST(LEFT(@value2,2)AS INT),@date_sum))
			end
		end
		else if (@len_string in (12,13,14,15)  and @count_string = 2)
		begin
			select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=2
			select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=3

			if ((@p_time_String like 'Hace [0-9][0-9] minutos') OR (@p_time_String like 'Hace [0-9] minutos') OR (@p_time_String like 'Hace [0-9][0-9] horas') OR (@p_time_String like 'Hace [0-9] horas'))
			begin
				  SET @date_sum  =
				              case
								 when @value2 = 'minutos' then  DATEADD(MI, - cast(@value1 as INT),@p_date_include)
								 when @value2 = 'horas'   then  DATEADD(hh, - cast(@value1 as INT),@p_date_include)
								 when @value2 = 'momento' then @p_date_include
							  end 
			end
			else if (@value2 ='momento') Begin   SET @date_sum =@p_date_include End
		end
		else if (@len_string in(3, 4,5,6) and  @count_string = 1)
		begin
			select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=1
			select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=2

			if ((@p_time_String like '[0-9] d' or  @p_time_String like '[0-9][0-9] d') or ( @p_time_String like '[0-9] h' or @p_time_String like '[0-9][0-9] h')  or ( @p_time_String like '[0-9] min' or @p_time_String like '[0-9][0-9] min'))
			begin
					SET @date_sum = (case 
										when @value2 = 'min' then DATEADD(MINUTE,- cast(@value1 as int),@p_date_include)  
										when @value2 = 'h'   then DATEADD(HH,- cast(@value1 as int),@p_date_include)
										when @value2 = 'd'   then DATEADD(DD,- cast(@value1 as int),@p_date_include)
								   ELSE NULL
								 end)

			end
		end
		else if (@len_string = (16) and  @count_string = 3)
		begin
			select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=4

			if (@p_time_String like 'ayer a las [0-2][0-9]:[0-5][0-9]')
			begin 
					SET @date_sum =  CAST(dateadd(DD, - 1,@p_date_include) AS date)
					SET @date_sum = DATEADD(MINUTE, CAST( RIGHT(@value2,2) AS INT), DATEADD(HH,CAST(LEFT(@value2,2)AS INT),@date_sum))
			end
		end
		else if (@len_string in (17,18) and @count_string = 4 )
		begin
				select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=1;
				select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=3;
				select  @value3=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=5;
				SET @value2 =  LOWER(REPLACE(@value2,'.',''))
				SET @date_sum =
				               case
									 when @value2 = 'ene' then DATEFROMPARTS ( cast(@value3 as int), 1, cast(@value1 as int) ) 
									 when @value2 = 'feb' then DATEFROMPARTS ( cast(@value3 as int), 2, cast(@value1 as int) )
									 when @value2 = 'mar' then DATEFROMPARTS ( cast(@value3 as int), 3, cast(@value1 as int) )
									 when @value2 = 'abr' then DATEFROMPARTS ( cast(@value3 as int), 4, cast(@value1 as int) )
									 when @value2 = 'may' then DATEFROMPARTS ( cast(@value3 as int), 5, cast(@value1 as int) )
									 when @value2 = 'jun' then DATEFROMPARTS ( cast(@value3 as int), 6, cast(@value1 as int) )
									 when @value2 = 'jul' then DATEFROMPARTS ( cast(@value3 as int), 7, cast(@value1 as int) )
									 when @value2 = 'ago' then DATEFROMPARTS ( cast(@value3 as int), 8, cast(@value1 as int) )
									 when @value2 = 'sep' then DATEFROMPARTS ( cast(@value3 as int), 9, cast(@value1 as int) )
									 when @value2 = 'oct' then DATEFROMPARTS ( cast(@value3 as int), 11, cast(@value1 as int) )
									 when @value2 = 'nov' then DATEFROMPARTS ( cast(@value3 as int), 12, cast(@value1 as int) )
									 when @value2 = 'dic' then DATEFROMPARTS ( cast(@value3 as int), 12, cast(@value1 as int) )
							   end
		end

		IF (@len_string in (12,13,14) and @count_string = 4)
		begin
				 
				 if (@p_time_String like 'Reels%')
				 begin
					select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=4;
					select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=5; 

					SET @date_sum = (case 
									when @value2 = 'min' then DATEADD(MM, - cast(@value1 as int),@p_date_include)  
									when @value2 = 'h'   then DATEADD(HH, - cast(@value1 as int),@p_date_include)
									when @value2 = 'd'   then DATEADD(DD, - cast(@value1 as int),@p_date_include)
								ELSE NULL
								end)
				 end
		end
		
		IF (@len_string in (13) and @count_string = 2)
		begin
				if (@p_time_String = 'Hace una hora')
				begin
					SET @date_sum  = DATEADD(HH, - 1,@p_date_include)
				end
		end

		IF(@len_string in (10,11,12,13) and @count_string = 2)
		begin			

					 --SET DATEFORMAT DMY;
					 SET @p_time_String = REPLACE(@p_time_String,'.','')
					 IF (@p_time_String   LIKE '[0-9][0-9] [a-zA-Z][a-zA-Z][a-zA-Z] [0-9][0-9][0-9][0-9]')
					 begin
						select  @value1=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=1;
						select  @value2=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=2;
						select  @value3=value from dbo.fnSplit(@p_time_String,SPACE(1)) as t where id=3;

						SET @date_sum =
				               case
									 when @value2 = 'ene' then DATEFROMPARTS ( cast(@value3 as int), 1, cast(@value1 as int) ) 
									 when @value2 = 'feb' then DATEFROMPARTS ( cast(@value3 as int), 2, cast(@value1 as int) )
									 when @value2 = 'mar' then DATEFROMPARTS ( cast(@value3 as int), 3, cast(@value1 as int) )
									 when @value2 = 'abr' then DATEFROMPARTS ( cast(@value3 as int), 4, cast(@value1 as int) )
									 when @value2 = 'may' then DATEFROMPARTS ( cast(@value3 as int), 5, cast(@value1 as int) )
									 when @value2 = 'jun' then DATEFROMPARTS ( cast(@value3 as int), 6, cast(@value1 as int) )
									 when @value2 = 'jul' then DATEFROMPARTS ( cast(@value3 as int), 7, cast(@value1 as int) )
									 when @value2 = 'ago' then DATEFROMPARTS ( cast(@value3 as int), 8, cast(@value1 as int) )
									 when @value2 = 'sep' then DATEFROMPARTS ( cast(@value3 as int), 9, cast(@value1 as int) )
									 when @value2 = 'oct' then DATEFROMPARTS ( cast(@value3 as int), 11, cast(@value1 as int) )
									 when @value2 = 'nov' then DATEFROMPARTS ( cast(@value3 as int), 12, cast(@value1 as int) )
									 when @value2 = 'dic' then DATEFROMPARTS ( cast(@value3 as int), 12, cast(@value1 as int) )
							   end
					 end
		end 
		return @date_sum
End
