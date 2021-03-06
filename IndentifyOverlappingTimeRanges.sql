-- Create a test table
SET NOCOUNT ON 
CREATE TABLE CalenderEvents (eventStart DATE, eventEnd DATE, eventName VARCHAR (100) NOT NULL)
INSERT INTO CalenderEvents 
		VALUES ('2015-10-25', '2015-11-04', 'planning'),
				('2015-11-05', '2015-11-06','coding'),
				('2015-11-15', '2015-12-01', 'testing'),
				('2015-09-26', '2015-09-29', 'requirement') 

-- At first check if there is invalid entries.
IF EXISTS (SELECT * FROM CalenderEvents WHERE eventStart > eventEnd) 
BEGIN	
	PRINT 'Table has invalid entries'
END 
ELSE 
BEGIN 
	-- Sort event entries based on eventStart
	SELECT RowNumber = ROW_NUMBER() OVER (ORDER BY eventStart),
			eventStart,
			eventEnd,
			eventName
			INTO #CalenderTableWithRowNumber  
			FROM CalenderEvents
			ORDER BY eventStart 


	DECLARE		@RowCount INT 
				,@IdCount INT = 1
	-- Compare two consecutive rows
	SELECT prev.RowNumber, prev.eventName AS previousEventName, curr.eventName AS currentEventName INTO #OverlappingEvents FROM #CalenderTableWithRowNumber curr
						INNER JOIN #CalenderTableWithRowNumber prev ON 
						((prev.RowNumber = curr.RowNumber - 1) 
							AND (prev.eventEnd >= curr.eventStart))
	SET @RowCount = @@ROWCOUNT

	IF (@RowCount > 0)
	BEGIN
		DECLARE @previousEventName VARCHAR (50)
				,@currentEventName VARCHAR (50)
		PRINT 'Overlapping time range exists'
		WHILE  (@RowCount >= @IdCount)
		BEGIN
			SELECT @previousEventName = previousEventName, 
					@currentEventName = currentEventName
					FROM #OverlappingEvents 
					WHERE RowNumber = @IdCount
			SET @IdCount = @IdCount + 1
			PRINT 'Overlapping ranges are with event name:' + @previousEventName + ':' + @currentEventName
		END  
	END 
	ELSE
	BEGIN
		PRINT 'No Overlapping time range exits'
	END 
END 