Set nocount on;
 
declare @p_search_words_one nvarchar(500)='Lima' 
declare @fechaInicial date ='2023-04-13'
declare @fechaFinal date ='2023-04-14' 


DECLARE @p_searchTextFilter NVARCHAR(200)='' ;
SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_one+'")'


DECLARE @vt_listFacebookpostbyFilterConditional TABLE ( Id  INT IDENTITY(1,1) PRIMARY KEY, PK_FacebookPost INT,
FacebookPostBodyText NVARCHAR(MAX),hashtagCount Int DEFAULT (0),hashtagValue  varchar(max),search_words_one_count int DEFAULT (0),search_words_one_Json VARCHAR(MAX), word varchar(100));
DECLARE @row_len  int =0, @row_count int = 0, @row_len_split int = 0 , @row_count_split INT = 0
DECLARE @vt_splitFacebookPostBodyTextbytext TABLE (Id INT IDENTITY(1,1) PRIMARY KEY, FK_FilterId int, Row# int, value nvarchar(max))
DECLARE @tt_text_search_words_include TABLE  ( id int identity ,ordinal int,search varchar(max), type int)
DECLARE @tt_text_resultWord_split TABLE (  id int identity , FilterConditionalId int,positionsentenceWord_One smallint,startPositionInText_One  
smallint,WordRowId_One smallint,searchWord_One varchar(100))
 

 
DECLARE @len_word tinyint, @firstWord varchar(50) 
INSERT INTO @vt_listFacebookpostbyFilterConditional (PK_FacebookPost,FacebookPostBodyText )
SELECT  PK_FacebookPost, FacebookPostBodyText FROM FacebookPost 
WHERE contains(FacebookPostBodyText,@p_searchTextFilter) 
 

select @row_len = count(1) from @vt_listFacebookpostbyFilterConditional c   

IF @row_len > 0
BEGIN

	-- El replace quita a la cadena de texto c.FacebookPostBodyText saltos de linea
	INSERT INTO @vt_splitFacebookPostBodyTextbytext (FK_FilterId,Row#,value )
	select c.Id,ROW_NUMBER() OVER(PARTITION BY PK_FacebookPost ORDER BY id ASC)  AS Row#,t.value 
	from @vt_listFacebookpostbyFilterConditional c cross apply STRING_SPLIT(REPLACE(REPLACE(REPLACE(c.FacebookPostBodyText,CHAR(9),''),CHAR(10),''),CHAR(13),''),SPACE(1)) as t
	
	-- Validate hashtag Count by FacebookPost
	UPDATE F  SET F.hashtagCount = ISNULL(T.hashtag_count,0) , F.hashtagValue =  T.hashtag_value 
	FROM (
	select FK_FilterId,count(1) hashtag_count  , STRING_AGG(h.value,',') hashtag_value
	from @vt_splitFacebookPostBodyTextbytext h where charindex('#',value) >0
	group by FK_FilterId  )  AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
	ON F.Id = T.FK_FilterId

	

	-- Validate count de palabras y la posicion en la cadena de texto. 
	-- Es valido para una palabra y una frase.
	insert into @tt_text_search_words_include(ordinal,search,type)
	select  c.id,value,1 from dbo.fnSplit(@p_search_words_one,SPACE(1))   c
	where  value<>''

	IF (select count (1) from @tt_text_search_words_include where type = 1 )  = 1
	BEGIN
			UPDATE F SET F.search_words_one_count = T.search_words_one_count , F.search_words_one_Json= T.search_words_oneJson
				FROM (
					SELECT FK_FilterId, COUNT(ValueJson) search_words_one_count, '[' + STRING_AGG(ValueJson,',') +']' search_words_oneJson  from (
					select d.FK_FilterId,
									   (select   '{"positionsentenceWord":' + cast(d.Row# as varchar(10))+', '+ '"searchWord":"'+ d.value +'", '+
									   '"startPositionInText":'+ CAST(
													   Len(STUFF((
													   SELECT   ' '+ f.value
													   FROM @vt_splitFacebookPostBodyTextbytext f
													   where f.FK_FilterId= d.FK_FilterId and f.Row# between 1 and  d.Row#
													   FOR XML PATH('')
												),1,1, '')) - len(d.value) as varchar(10)) +', "lentext":'+ cast(len(d.value) as varchar(10))+ '}'  ) ValueJson
				   from @vt_splitFacebookPostBodyTextbytext as  d  
				   where  d.value like ''+@p_search_words_one+'%' )L
				   group by FK_FilterId		)  AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
				   ON F.Id = T.FK_FilterId
				   where f.Id = t.FK_FilterId 


				   INSERT INTO @tt_text_resultWord_split (FilterConditionalId,positionsentenceWord_One,searchWord_One,startPositionInText_One,WordRowId_One)
				   SELECT d.FK_FilterId,    cast(d.Row# as varchar(10))  positionsentenceWord ,  d.value searchWord ,
									     CAST(
													   Len(STUFF((
													   SELECT   ' '+ f.value
													   FROM @vt_splitFacebookPostBodyTextbytext f
													   where f.FK_FilterId= d.FK_FilterId and f.Row# between 1 and  d.Row#
													   FOR XML PATH('')
												),1,1, '')) - len(d.value) as varchar(10)) startPositionInText  ,  
												ROW_NUMBER() OVER(PARTITION BY FK_FilterId ORDER BY id ASC) rowid
				   FROM @vt_splitFacebookPostBodyTextbytext as  d  
				   WHERE  d.value like ''+@p_search_words_one+'%' 
	END 
END
select c.PK_FacebookPost,hashtagCount,search_words_one_count, search_words_one_Json , B.positionsentenceWord_One,B.startPositionInText_One,B.WordRowId_One, searchWord_One searchWord_One
from @vt_listFacebookpostbyFilterConditional  c cross apply  ( select FilterConditionalId, cv.positionsentenceWord_One,cv.startPositionInText_One,cv.WordRowId_One,cv.searchWord_One from @tt_text_resultWord_split cv where c.id= cv.FilterConditionalId ) B 
where c.Id = b.FilterConditionalId