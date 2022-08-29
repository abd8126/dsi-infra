
currentDate=$(date +%Y%m%d)

## This file is to store all the relevant tests for each API

function countNumberOfRecords(){

## This checks for the number of records currently contained within the landing and data repo tables for each API
# Define the SQL query statement for the landing data


landingQueryString=$(echo 'SELECT COUNT(*) FROM "'$1'"."'$3'"' )

# Define the SQL query statement for the data repo data
dataRepoQueryString=$(echo 'SELECT COUNT(*) FROM "'$2'"."'$3'"')

# Run the query function passing parameters defined above
startQueryExecution $1 $2 "$landingQueryString" "$dataRepoQueryString" $queryResultsLocation $4

# This function returns the query results
# passing back variables named $landingQueryJSON and $datarepoQueryJSON
returnQueryResults

# This variable contains the record count for the landing data
export landingRecordCount=$(echo "$landingQueryJSON" | jq -r '.ResultSet.Rows[1].Data[0].VarCharValue')

# This variable contains the record count for the data repo data
export datarepoRecordCount=$(echo "$datarepoQueryJSON" | jq -r '.ResultSet.Rows[1].Data[0].VarCharValue')

 LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
 echo "                                           "
 echo $LOGTIME": *********************"$apiTableName"*********************" | tee -a LOG
 echo $LOGTIME": Landing record count:    "$landingRecordCount"" | tee -a LOG
 echo $LOGTIME": Data repo record count:  "$datarepoRecordCount"" | tee -a LOG


}

function testForLastRecievedData(){

## The following is a list of arguments passed into this function from athenacontrol.sh:

# $1: Landing database name
# $2: Data Repo database name
# $3: Api table name
# $4: Athena WorkGroup name
# $5: Frequency of data ingest

# Return the date of the last record for both the landing and data repo databases
# This test is applicable for any API which gets updated by new records being added to the table at each ingest

# Define the SQL query statement for the landing data
# Which gets the latest record to come in

landingQueryString=$(echo 'SELECT "date" FROM "'$1'"."'$3'" ORDER BY "date" DESC limit 1' )

# Define the SQL query statement for the data repo data
dataRepoQueryString=$(echo 'SELECT "date" FROM "'$2'"."'$3'" ORDER BY "date" DESC limit 1' )

# Run the query function passing parameters defined above
startQueryExecution $1 $2 "$landingQueryString" "$dataRepoQueryString" $queryResultsLocation $4

# This function returns the query results
# passing back variables named $landingQueryJSON and $datarepoQueryJSON
returnQueryResults

# This variable contains the latest date for the landing data
lastRecievedLanding=$(echo "$landingQueryJSON" | jq -r '.ResultSet.Rows[1].Data[0].VarCharValue')
lastRecievedLanding=`sed -e 's/^"//' -e 's/"$//' <<<"$lastRecievedLanding"`


# This variable contains the latest date for the data repo data
lastRecievedDatarepo=$(echo "$datarepoQueryJSON" | jq -r '.ResultSet.Rows[1].Data[0].VarCharValue')
lastRecievedDatarepo=`sed -e 's/^"//' -e 's/"$//' <<<"$lastRecievedDatarepo"` 



## Test:

# Test status for the landing data that it has been recieved within the timeframe define by the frequency of ingest.
# Note this test could be changed to test that data was recieved at a certain date of the month

recievedLandingDate=$(echo "$lastRecievedLanding" | tr -d "-")

if [ $recievedLandingDate -ge  $((currentDate - $5))  ]
then
    landingStatus=SUCCESS
else
    landingStatus=FAILED
fi

# Test status for the data repo data
recievedDatarepoDate=$(echo "$lastRecievedDatarepo" | tr -d "-")

if [ $recievedDatarepoDate -ge  $((currentDate - $5))  ]
then
	datarepoStatus=SUCCESS
else
	datarepoStatus=FAILED
fi

#Print Test results to the console and log to the logging file

 LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
 #LOGFILENAME=$("LOG"`date "+%Y-%m-%d"`)
 echo "                                           "
 echo $LOGTIME": ******************TEST: "$apiTableName"*********************" | tee -a LOG
 echo $LOGTIME": Testing:     Checking date of last recieved record from the landing database" | tee -a LOG
 echo $LOGTIME": Result:      "$lastRecievedLanding | tee -a LOG
 echo $LOGTIME": Status:      "$landingStatus  | tee -a LOG
 echo $LOGTIME":                                            " | tee -a LOG


#Print Test results to the console and log to the logging file
 echo $LOGTIME":                                            " | tee -a LOG
 echo $LOGTIME": ******************TEST: "$apiTableName"*********************" | tee -a LOG
 echo $LOGTIME": Testing:     Checking date of last recieved record from the data repo database" | tee -a LOG
 echo $LOGTIME": Result:      "$lastRecievedDatarepo | tee -a LOG
 echo $LOGTIME": Status:      "$datarepoStatus       | tee -a LOG
 echo $LOGTIME":                                            " | tee -a LOG

# Check if the landing or the data repo failed and then return an exit code

if [ $landingStatus=FAILED ] || [ $datarepoStatus=FAILED ]
then
    return 0
else
    return 1
fi
#aws s3 cp LOGFILENAME $testLogLocation$LOGFILENAME
}