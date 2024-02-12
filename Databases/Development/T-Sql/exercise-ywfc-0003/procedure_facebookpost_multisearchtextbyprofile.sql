USE [MetaCollection]
GO
/****** Object:  StoredProcedure [dbo].[usp_facebook_mutisearchtextbyprofile]    Script Date: 08/02/2024 02:09:28  ******/

CREATE PROCEDURE usp_facebook_mutisearchtextbyprofile
(
@FK_SearchProjectCollection int = 1,
@pk_perfil int = 2,
@fechaInicial date ='2024-01-01',  
@fechaFinal date ='2024-08-17'
)
AS BEGIN
set nocount on;
-- tables temporales
declare @tt_word_perfil_sarch_text table (id int identity(1,1), text varchar(100), typetext  int , FK_SearchCategory int,FK_SearchText int);


declare @p_position_indexsarch int, @p_split_search int =45,@p_search_text_first varchar(100), @p_search_text_split varchar(100)
IF OBJECT_ID('tempdb.dbo.#tt_split_word_bysearch_facebook', 'U') IS NOT NULL DROP TABLE #tt_split_word_bysearch_facebook; 
create table  #tt_split_word_bysearch_facebook   ( id int identity(1,1) , text  varchar(100), typetext int);

----Word
 declare @tt_result_between_time table (Id int identity(1,1), PK_FacebookPost bigint, hashtagCount smallint, hashtagValue varchar(500), search_words_one_count int,	search_words_one_Json nvarchar(max) ,	positionsentenceWord_One smallint,startPositionInText_One smallint,	WordRowId_One smallint,	searchWord_One varchar(100),FK_SearchCategory int ,FK_SearchText int, complit_split bit default(1))
 
----two word
declare @tt_result_Final_score table (id int identity(1,1) ,FK_SearchCategory int ,FK_SearchText int,PK_FacebookPost bigint,hashtagCount smallint,hashtagValue varchar(500),search_words_one_count int,search_words_one_Json  nvarchar(max),search_words_two_count int,	search_words_two_Json nvarchar(max),positionsentenceWord_One int,startPositionInText_One int,WordRowId_One int,	searchWord_One varchar(100),positionsentenceWord_Two  int,	startPositionInText_Two int,WordRowId_Two int,searchWord_Two varchar(100),COMPLETE_SPLIT bit default(0))


--Operacion
Declare @p_count_search int =0, @p_total_search int;

declare @p_Text varchar(100) , @p_TypeText int , @p_FK_SearchCategory int, @FK_SearchText int;

insert into @tt_word_perfil_sarch_text(text, typetext,FK_SearchCategory,FK_SearchText)
select Text, TypeText, FK_SearchCategory, d.PK_SearchText from      [dbo].[SearchCategory]c with (nolock) inner join [dbo].[SearchText] d with (nolock)
on c.PK_SearchCategory= d.FK_SearchCategory
where c.FK_SearchProfile= @pk_perfil

select @p_total_search = count(1) from @tt_word_perfil_sarch_text ;

--select * from @tt_word_perfil_sarch_text;

while (@p_count_search<@p_total_search)
begin
		set @p_count_search+=1;
		 
		 
		select @p_Text=Text, @p_TypeText=TypeText, @p_FK_SearchCategory=FK_SearchCategory, @FK_SearchText= FK_SearchText  from @tt_word_perfil_sarch_text where id=@p_count_search;

		--select @p_Text, @p_TypeText,@p_FK_SearchCategory,@FK_SearchText
		select  @p_position_indexsarch= CHARINDEX('(',@p_Text)
		Set @p_split_search=45
		if (@p_position_indexsarch >0) 
		begin  
 
				select @p_split_search = SUBSTRING(@p_Text,CHARINDEX('(',@p_Text)+1,(CHARINDEX(')',@p_Text)-CHARINDEX('(',@p_Text))-1)
		end
		
		insert into #tt_split_word_bysearch_facebook(text,typetext)
		select value ,@p_TypeText from dbo.SplitStrings_Ordered(@p_Text,',') as t

		--select * from #tt_split_word_bysearch
		if (@p_TypeText=1)
		begin
			 begin try
				set @p_search_text_first=''; set @p_search_text_split ='';
				select @p_search_text_first= text  from #tt_split_word_bysearch_facebook where id=1
				Set  @p_search_text_first =REPLACE(REPLACE(@p_search_text_first,'"',''),'"','')
		 
				-- select @p_search_text_first,@p_search_text_split,@p_split_search,@fechaInicial,@fechaFinal
				-- Usar el store procedure 
					insert into @tt_result_between_time(PK_FacebookPost,hashtagCount,hashtagValue,search_words_one_count,search_words_one_Json,positionsentenceWord_One,startPositionInText_One,WordRowId_One ,	searchWord_One) 
					EXEC SocialCloud.dbo.usp_searchFacebookPost_phrase  @p_search_words_one = @p_search_text_first ,
					@fechaInicial  = @fechaInicial,
					@fechaFinal	   = @fechaFinal;
				   
				    update @tt_result_between_time set FK_SearchCategory=  @p_FK_SearchCategory , FK_SearchText =@FK_SearchText  
				    where FK_SearchCategory is null and FK_SearchText is null

			 end try
			 begin catch
				
				  SELECT  ERROR_NUMBER() AS ErrorNumber,ERROR_STATE() AS ErrorState, ERROR_SEVERITY() AS ErrorSeverity,ERROR_PROCEDURE() AS ErrorProcedure,ERROR_LINE() AS ErrorLine,ERROR_MESSAGE() AS ErrorMessage;
					  select @p_search_text_first,@p_search_text_split,@p_split_search,@fechaInicial,@fechaFinal
					  break;

			 end catch;
		end	
		else if (@p_TypeText= 2)
		begin
		   begin try
				set @p_search_text_first=''; set @p_search_text_split ='';
				select @p_search_text_first= text  from #tt_split_word_bysearch_facebook where id=1
				select @p_search_text_split= text  from #tt_split_word_bysearch_facebook where id=2
			    Set  @p_search_text_first = LTRIM(RTRIM(REPLACE(REPLACE(@p_search_text_first,'"',''),'"','')));
				sET @p_search_text_split = LTRIM(RTRIM(REPLACE(REPLACE(@p_search_text_split,'"',''),'"','')));
			
				--  select @p_search_text_first,@p_search_text_split,@p_split_search,@fechaInicial,@fechaFinal
				-- Usar el store procedure  
					INSERT INTO @tt_result_Final_score (PK_FacebookPost ,hashtagCount ,hashtagValue ,search_words_one_count ,search_words_one_Json,search_words_two_count,search_words_two_Json,positionsentenceWord_One ,startPositionInText_One ,WordRowId_One,searchWord_One,positionsentenceWord_Two  ,	startPositionInText_Two ,WordRowId_Two,searchWord_Two ,COMPLETE_SPLIT)
					EXEC  SocialCloud.DBO.usp_searchFacebookPost_Multiphrase  
					  @p_search_words_one  =p_search_words_one,
					  @p_search_words_two  =@p_search_text_split,
					  @p_search_not_words_four  ='',
					  @fechaInicial =  @fechaInicial,
					  @fechaFinal = @fechaFinal,
					  @p_between_list_word     = @p_split_search;


				update @tt_result_Final_score set FK_SearchCategory=  @p_FK_SearchCategory , FK_SearchText =@FK_SearchText  
				where FK_SearchCategory is null and FK_SearchText is null
			end try
			begin catch 
				      SELECT  ERROR_NUMBER() AS ErrorNumber,ERROR_STATE() AS ErrorState, ERROR_SEVERITY() AS ErrorSeverity,ERROR_PROCEDURE() AS ErrorProcedure,ERROR_LINE() AS ErrorLine,ERROR_MESSAGE() AS ErrorMessage;
					  select @p_search_text_first,@p_search_text_split,@p_split_search,@fechaInicial,@fechaFinal

					break;
			end catch
		end 
		truncate table #tt_split_word_bysearch_facebook;
end
IF OBJECT_ID('tempdb.dbo.#tt_split_word_bysearch_facebook', 'U') IS NOT NULL DROP TABLE #tt_split_word_bysearch_facebook; 

--select * from @tt_result_Final_score;
--delete from  SearchProjectfacebooktranscriptionResult where FK_SearchProjectCollection=@FK_SearchProjectCollection

----- creación 
MERGE [dbo].SearchProjectFacebookPostResult AS Target
USING @tt_result_between_time	AS Source
ON  (Target.FK_SearchProjectCollection) = @FK_SearchProjectCollection and (Source.FK_SearchText = Target.FK_SearchText) and (Source.PK_FacebookPost = Target.PK_FacebookPost) AND (TARGET.SearchTextType = 1)
WHEN NOT MATCHED BY Target THEN
    INSERT (FK_SearchProjectCollection, FK_SearchText, PK_FacebookPost, hashtagCount, hashtagValue, search_words_count, search_words_Json, positionsentenceWord, startPositionInText, WordRowId, Complete_split,SearchTextType) 
    VALUES (@FK_SearchProjectCollection, Source.FK_SearchText,Source.PK_FacebookPost,Source.hashtagCount, Source.hashtagValue,Source.search_words_One_count,source.search_words_One_Json,source.positionsentenceWord_one,source.startPositionInText_one,source.WordRowId_One,source.complit_split,1);



MERGE [dbo].SearchProjectFacebookPostResult AS Target
USING @tt_result_Final_score	AS Source
ON  (Target.FK_SearchProjectCollection) = @FK_SearchProjectCollection and (Source.FK_SearchText = Target.FK_SearchText) and (Source.PK_FacebookPost = Target.PK_FacebookPost) AND (TARGET.SearchTextType = 2)
WHEN NOT MATCHED BY Target THEN
    INSERT (FK_SearchProjectCollection, FK_SearchText, PK_FacebookPost, hashtagCount, hashtagValue, search_words_count, search_words_Json, positionsentenceWord, startPositionInText, WordRowId, search_words_Cuts_count, search_words_Cuts_Json, positionsentenceWord_Cuts, startPositionInText_Cuts, WordRowId_Cuts, Complete_split,SearchTextType) 
    VALUES (@FK_SearchProjectCollection, FK_SearchText,Source.PK_FacebookPost,Source.hashtagCount, source.hashtagValue,source.search_words_One_count,source.search_words_One_Json,source.positionsentenceWord_One,source.startPositionInText_One,source.WordRowId_one,source.search_words_two_count,source.search_words_Two_Json, source.positionsentenceWord_two, source.startPositionInText_two, source.WordRowId_two, source.Complete_split,2);

END;