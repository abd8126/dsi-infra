#!/bin/bash

# This is the query configuration file

# Athena queries as part of the automatic testing framework

# Run using athenacontrol.sh


# This function creates the Athena Query using a SQL Statement to query the AWS DATA CATALOG
function startQueryExecution(){



# Run the query. This outputs the query execution ID, which will be used to access the query result


landingExecutionIdJson=$(aws athena start-query-execution \
    --query-string "$3" \
    --work-group primary \
    --region eu-west-2 \
    --query-execution-context Database=$1,Catalog=AwsDataCatalog \
    --result-configuration OutputLocation=$5)

   # extract the ID from the JSON output
   export landingExecutionId=$(echo "$landingExecutionIdJson" | jq -r .QueryExecutionId)


datarepoExecutionIdJson=$(aws athena start-query-execution \
    --query-string "$4" \
    --work-group primary \
    --region eu-west-2 \
    --query-execution-context Database=$2,Catalog=AwsDataCatalog \
    --result-configuration OutputLocation=$5)

   # extract the ID from the JSON output
   export datarepoExecutionId=$(echo "$datarepoExecutionIdJson" | jq -r .QueryExecutionId)
}

# This function outputs the query results as a JSON object and then checks for latest record.

function returnQueryResults(){
 export landingQueryJSON=$(aws athena get-query-results --query-execution-id $landingExecutionId  --region eu-west-2)
 export datarepoQueryJSON=$(aws athena get-query-results --query-execution-id $datarepoExecutionId  --region eu-west-2)
}

