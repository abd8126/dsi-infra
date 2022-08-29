#!/bin/bash

# This is the main control file

source athena.sh
source tests.sh

## define env variables

athenaWorkGroupName=primary
#Specify the landing and data repository databases to be queried
apiLDBName="dsi-landing"
apiDRDBName="dsi-data-repository"

# Define the s3 bucket location to store the query result currently defined for DEVL
export queryResultsLocation='s3://aws-athena-query-results-515924272305-eu-west-2/athena_results/'
export testLogLocation=$queryResultsLocation"/log/"


###Test for API-1 Admission Metrics - Returns latest record that has been ingested in the landing and data repo database

apiTableName="api1_admission_metrics"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
# set $onlyTest=true if this is the only test
countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName  $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for API-1 stp_level - Returns latest record that has been ingested in the landing and data repo database

apiTableName="api_00001_stp_level"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for api1_nhs_metrics - Returns latest record that has been ingested in the landing and data repo database

apiTableName="api1_nhs_metrics"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName  $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for api_00002_weather_warning - Returns latest record that has been ingested in the landing and data repo database

apiTableName="api_00002_weather_warning"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest

##Test for boc - Returns latest record that has been ingested in the landing and data repo database

apiTableName="boc"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for cqc_social_care_daily_details - Returns latest record that has been ingested in the landing and data repo database

apiTableName="cqc_social_care_daily_details"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for met_office_flood_guidance - Returns latest record that has been ingested in the landing and data repo database

apiTableName="met_office_flood_guidance"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest


##Test for nhs-winter-risks - Returns latest record that has been ingested in the landing and data repo database

apiTableName="nhs-winter-risks"

# This test is applicable for each API as it checks the record count and must be run before any additional tests
#countNumberOfRecords $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName

## Test for latest record date:

## Define how often in days is this data meant to be ingested ##
frequencyOfDataIngest=30

#Run the last record ingest test
#testForLastRecievedData $apiLDBName $apiDRDBName $apiTableName $athenaWorkGroupName $frequencyOfDataIngest
