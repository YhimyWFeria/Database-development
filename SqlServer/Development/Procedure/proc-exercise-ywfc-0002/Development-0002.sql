Set nocount on;
 
declare @p_search_words_one nvarchar(500)='Cercado de Lima'
declare @p_search_words_two varchar(100) ='obras'
declare @p_search_not_words_four varchar(100) =''
declare @P_TypeSearch int   = 0;
declare @fechaInicial date ='2023-04-13'
declare @fechaFinal date ='2023-04-14'

IF(LEN(ISNULL(@p_search_words_one,'')) >1  AND  LEN(ISNULL(@p_search_words_two,'')) =0 AND LEN(ISNULL(@p_search_not_words_four,'')) =0) BEGIN SET @P_TypeSearch = 1 END 
IF(LEN(ISNULL(@p_search_words_one,'')) >1  AND  LEN(ISNULL(@p_search_words_two,'')) =0 AND LEN(ISNULL(@p_search_not_words_four,'')) >1) BEGIN SET @P_TypeSearch = 2 END 
IF(LEN(ISNULL(@p_search_words_one,'')) =0  AND  LEN(ISNULL(@p_search_words_two,'')) >1 AND LEN(ISNULL(@p_search_not_words_four,'')) =0) BEGIN SET @P_TypeSearch = 3 END  
IF(LEN(ISNULL(@p_search_words_one,'')) =0  AND  LEN(ISNULL(@p_search_words_two,'')) >1 AND LEN(ISNULL(@p_search_not_words_four,'')) >1) BEGIN SET @P_TypeSearch = 4 END  
IF(LEN(ISNULL(@p_search_words_one,'')) >1  AND  LEN(ISNULL(@p_search_words_two,'')) >1 AND LEN(ISNULL(@p_search_not_words_four,'')) =0) BEGIN SET @P_TypeSearch = 5 END  
IF(LEN(ISNULL(@p_search_words_one,'')) >1  AND  LEN(ISNULL(@p_search_words_two,'')) >1 AND LEN(ISNULL(@p_search_not_words_four,'')) >1) BEGIN SET @P_TypeSearch = 6 END  
  

DECLARE @p_searchTextFilter NVARCHAR(200)='' ;

IF (@P_TypeSearch = 1) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_one+'")'  END
IF (@P_TypeSearch = 2) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_one+'")  AND NOT FORMSOF (INFLECTIONAL, "'+@p_search_not_words_four+'")'   END
IF (@P_TypeSearch = 3) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_two+'")'  END
IF (@P_TypeSearch = 4) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_two+'")  AND NOT FORMSOF (INFLECTIONAL, "'+@p_search_not_words_four+'")'   END
IF (@P_TypeSearch = 5) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_one+'")  AND FORMSOF (INFLECTIONAL, "'+@p_search_words_two+'")'  END
IF (@P_TypeSearch = 6) BEGIN SET @p_searchTextFilter =' FORMSOF (INFLECTIONAL, "'+@p_search_words_one+'")  AND FORMSOF (INFLECTIONAL, "'+@p_search_words_two+'") AND NOT FORMSOF (INFLECTIONAL, "'+@p_search_not_words_four+'")'  END
 
DECLARE @vt_listFacebookpostbyFilterConditional TABLE ( Id  INT IDENTITY(1,1) PRIMARY KEY, PK_FacebookPost INT,
FacebookPostBodyText NVARCHAR(MAX),hashtagCount Int DEFAULT (0),hashtagValue  varchar(max),search_words_one_count int DEFAULT (0),search_words_one_Json VARCHAR(max), 
search_words_two_count INT DEFAULT (0),search_words_two_Json VARCHAR(max));
DECLARE @row_len  int =0, @row_count int = 0, @row_len_split int = 0 , @row_count_split INT = 0
DECLARE @vt_splitFacebookPostBodyTextbytext TABLE (Id INT IDENTITY(1,1) PRIMARY KEY, FK_FilterId int, Row# int, value nvarchar(max))
declare @tt_text_search_words_include table  ( id int identity ,ordinal int,search varchar(max), type int)
DECLARE @len_word tinyint, @firstWord varchar(50)

INSERT INTO @vt_listFacebookpostbyFilterConditional (PK_FacebookPost,FacebookPostBodyText )
SELECT  PK_FacebookPost, FacebookPostBodyText FROM FacebookPost 
WHERE contains(FacebookPostBodyText,@p_searchTextFilter) 
 
select @row_len = count(1) from @vt_listFacebookpostbyFilterConditional c   
 
IF @row_len > 0
BEGIN
	INSERT INTO @vt_splitFacebookPostBodyTextbytext (FK_FilterId,Row#,value )
	select Id,ROW_NUMBER() OVER(PARTITION BY PK_FacebookPost ORDER BY id ASC)  AS Row#,t.value 
	from @vt_listFacebookpostbyFilterConditional c cross apply STRING_SPLIT(c.FacebookPostBodyText,SPACE(1)) as t

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
	where  value<>'';
  
	insert into @tt_text_search_words_include(ordinal,search,type)
	select c.id,value,2 from dbo.fnSplit(@p_search_words_two,SPACE(1))   c
	where  value<>'';

	IF (select count (1) from @tt_text_search_words_include where type = 1 )  = 1
	BEGIN			

				UPDATE F SET F.search_words_one_count = T.search_words_one_count , F.search_words_one_Json= T.search_words_oneJson
				FROM (
					SELECT FK_FilterId, COUNT(ValueJson) search_words_one_count, '[' + STRING_AGG(ValueJson,',') +']' search_words_oneJson  from (
					select d.FK_FilterId,
									   (select   '{positionsentenceWord:' + cast(d.Row# as varchar(10))+', '+ 'searchWord:"'+ d.value +'", '+
									   'startPositionInText:'+ CAST(
													   Len(STUFF((
													   SELECT   ' '+ f.value
													   FROM @vt_splitFacebookPostBodyTextbytext f
													   where f.FK_FilterId= d.FK_FilterId and f.Row# between 1 and  d.Row#
													   FOR XML PATH('')
												),1,1, '')) - len(d.value) as varchar(10)) +', lentext:'+ cast(len(d.value) as varchar(10))+ '}'  ) ValueJson
				   from @vt_splitFacebookPostBodyTextbytext as  d  
				   where  d.value like ''+@p_search_words_one+'%' )L
				   group by FK_FilterId		)  AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
				   ON F.Id = T.FK_FilterId
	end
	ELSE IF (select count (1) from @tt_text_search_words_include where type = 1 )  > 1
	BEGIN
		
			 select @len_word=COUNT(1) from @tt_text_search_words_include  where type = 1
			 select @firstWord = search from @tt_text_search_words_include  where type =1 and ordinal = 1
		 

			 UPDATE  F SET F.search_words_one_count = T.search_words_one_count , F.search_words_one_Json= T.search_words_oneJson
			 FROM (
					 SELECT FK_FilterId,COUNT(ValueJson) search_words_one_count, '[' + STRING_AGG(ValueJson,',') +']' search_words_oneJson  FROM (
					 Select FK_FilterId ,( '{positionsentenceWord:' + cast(isnull(S.Row#,0) as varchar(10))+', '+ 'searchWord:"'+ S.Phrase +'", '+
					 'startPositionInText:'+ CAST(LEN(ISNULL(STUFF((
															   SELECT   ' '+ f.value
															   FROM @vt_splitFacebookPostBodyTextbytext f
															   where f.FK_FilterId= S.FK_FilterId and f.Row# between 1 and  ((s.Row# + @len_word)-1) 
															   FOR XML PATH('')
														),1,1, ''),'')) - len(S.value)  AS VARCHAR(10))+', lentext:'+ cast(ISNULL(len(S.Phrase),0) as varchar(10))+ '}' ) AS ValueJson
		 
					 from (
					 select FK_FilterId, Row#, value ,
										STUFF((
															   SELECT   ' '+ f.value
															   FROM @vt_splitFacebookPostBodyTextbytext f
															   where f.FK_FilterId= d.FK_FilterId and f.Row# between d.Row# and  ((d.Row# + @len_word)-1)
															   FOR XML PATH('')
														),1,1, '') as Phrase
					  FROM   @vt_splitFacebookPostBodyTextbytext d  where value = @firstWord	) S
					  WHERE S.Phrase =  @p_search_words_one							 ) LO 
					  GROUP BY FK_FilterId 
			  ) AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
			  ON F.Id = T.FK_FilterId

	END	
 
	IF (select count (1) from @tt_text_search_words_include where type = 2 )  = 1
	BEGIN			

				UPDATE F SET F.search_words_two_count = T.search_words_two_count , F.search_words_two_Json= T.search_words_twoJson
				FROM (
					SELECT FK_FilterId, COUNT(ValueJson) search_words_two_count, '[' + STRING_AGG(ValueJson,',') +']' search_words_twoJson  from (
					select d.FK_FilterId,
									   (select   '{positionsentenceWord:' + cast(isnull(d.Row#,0) as varchar(10))+', '+ 'searchWord:"'+ d.value +'", '+
									   'startPositionInText:'+ CAST(
													   ISNULL(Len(STUFF((
													   SELECT   ' '+ f.value
													   FROM @vt_splitFacebookPostBodyTextbytext f
													   where f.FK_FilterId= d.FK_FilterId and f.Row# between 1 and  d.Row#
													   FOR XML PATH('')
												),1,1, '')) - len(d.value),0) as varchar(10)) +', lentext:'+ cast(ISNULL(len(d.value),0) as varchar(10))+ '}'  ) ValueJson
				   from @vt_splitFacebookPostBodyTextbytext as  d  
				   where  d.value like ''+@p_search_words_two+'%' )L
				   group by FK_FilterId		)  AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
				   ON F.Id = T.FK_FilterId
	end
	ELSE IF (select count (1) from @tt_text_search_words_include where type = 2 )  >  1
	BEGIN
			 SELECT @len_word=COUNT(1) from @tt_text_search_words_include  where type = 2
			 SELECT @firstWord = search from @tt_text_search_words_include  where type =2 and ordinal = 1
		 

			 UPDATE  F SET F.search_words_two_count = T.search_words_two_count , F.search_words_two_Json= T.search_words_twoJson
			 FROM (
					 SELECT FK_FilterId,COUNT(ValueJson) search_words_two_count, '[' + STRING_AGG(ValueJson,',') +']' search_words_twoJson  FROM (
					 Select FK_FilterId ,( '{positionsentenceWord:' + cast(isnull(S.Row#,0) as varchar(10))+', '+ 'searchWord:"'+ S.Phrase +'", '+
					 'startPositionInText:'+ CAST(LEN(ISNULL(STUFF((
															   SELECT   ' '+ f.value
															   FROM @vt_splitFacebookPostBodyTextbytext f
															   where f.FK_FilterId= S.FK_FilterId and f.Row# between 1 and  ((s.Row# + @len_word)-1) 
															   FOR XML PATH('')
														),1,1, ''),'')) - len(S.value)  AS VARCHAR(10))+', lentext:'+ cast(ISNULL(len(S.Phrase),0) as varchar(10))+ '}' ) AS ValueJson
		 
					 from (
					 select FK_FilterId, Row#, value ,
										STUFF((
															   SELECT   ' '+ f.value
															   FROM @vt_splitFacebookPostBodyTextbytext f
															   where f.FK_FilterId= d.FK_FilterId and f.Row# between d.Row# and  ((d.Row# + @len_word)-1)
															   FOR XML PATH('')
														),1,1, '') as Phrase
					  FROM   @vt_splitFacebookPostBodyTextbytext d  where value = @firstWord	) S
					  WHERE S.Phrase =  @p_search_words_two							 ) LO 
					  GROUP BY FK_FilterId 
			  ) AS T INNER JOIN @vt_listFacebookpostbyFilterConditional f
			  ON F.Id = T.FK_FilterId
	END
END
SELECT * FROM @vt_listFacebookpostbyFilterConditional c
 
 