create procedure sp_ProxyFullplate
as begin

DECLARE @Alphabet varchar(100),@Post1LeT int,@ContT1Alphabet int,@Alm1TL char(1)
DECLARE @Alphabet2T varchar(100),@Post2LeT int,@Alm2TL char(1),@ContAlphabet2T int
DECLARE @Alphabet3T varchar(100),@Post3LeT int,@Alm3TL char(1),@ContAlphabet3T int
DECLARE	@Value varchar(6),@valInc1 int,@LentAlphabet int;
	
set @valInc1=0;
set @Value='';
set @ContT1Alphabet=0;
set @ContAlphabet2T=0;
set @ContAlphabet3T=0
set @Alphabet='ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
set @Alphabet2T='ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
set @Alphabet3T='ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
set @LentAlphabet=27

--select  (@Alphabet2T)
set @Post1LeT=1
set @Post2LeT=1
set @Post3LeT=1
		while(@ContT1Alphabet<@LentAlphabet)
		begin
			  set @Alm1TL= SUBSTRING(@Alphabet,@Post1LeT,1)
               while (@ContAlphabet2T<@LentAlphabet)
			    begin
				   set @Alm2TL= SUBSTRING(@Alphabet2T,@Post2LeT,1)
				    while ( @ContAlphabet3T<@LentAlphabet)
                     begin
					    set @Alm3TL= SUBSTRING(@Alphabet3T,@Post3LeT,1);
						   while(@valInc1<=999)
						     begin
							  set @Value = cast(@Alm1TL + @Alm2TL + @Alm3TL + RIGHT('000' + CAST(@valInc1 as varchar), 3) as varchar(6))
							   insert into [ProxyPlate]([Platetext])values(@Value)
							  set @valInc1+=1
							 end
						 set @Post3LeT+=1
						 set @valInc1=0
						 set @ContAlphabet3T+=1
                      end
					set @Post2LeT+=1
					set @valInc1=0
					set @Post3LeT=1
					set @ContAlphabet3T=0
					set @ContAlphabet2T+=1
				 end
			 set @ContT1Alphabet +=1
			 set @Post1LeT+=1
			 set @Post2LeT=1
			 set @Post3LeT=1
			 set @ContAlphabet2T=0
			 set @ContAlphabet3T=0
		  end
end
go
--AAA000 hasta ZZZ999
