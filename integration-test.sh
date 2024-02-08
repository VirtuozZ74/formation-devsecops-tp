#!/bin/bash
#integration-test.sh

if [[ ! -z "30619" ]];
then
    response=$(curl -s http://mytpm.eastus.cloudapp.azure.com:30619)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://mytpm.eastus.cloudapp.azure.com:30619)
    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1;
    fi;
    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed"
        else
            echo "HTTP Status code is not 200"
            exit 1;
    fi;
else
        echo "The Service does not have a NodePort"
        exit 1;
fi;