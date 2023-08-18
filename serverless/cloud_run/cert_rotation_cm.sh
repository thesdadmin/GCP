#!/bin/bash

set -euox pipefail
CLOUD_RUN_TASK_INDEX=${CLOUD_RUN_TASK_INDEX:=0}
CLOUD_RUN_TASK_ATTEMPT=${CLOUD_RUN_TASK_ATTEMPT:=0}


echo "Starting Task #${CLOUD_RUN_TASK_INDEX}, Attempt #${CLOUD_RUN_TASK_ATTEMPT}..."


# SLEEP_MS and FAIL_RATE should be a decimal
# numbers. parse and format the input using 
# printf. 
#
# printf validates the input since it 
# quits on invalid input, as shown here:
#
#   $: printf '%.1f' "abc"
#   bash: printf: abc: invalid number
#
SLEEP_MS=$(printf '%.1f' "${SLEEP_MS:=0}")
FAIL_RATE=$(printf '%.1f' "${FAIL_RATE:=0}")

 #If there are multiple certificates for different domains, we need to add a "AND" to the filter statement and parse by domain name
RESULT=$(gcloud certificate-manager certificates list --filter="expireTime < P15D" --format="value(name)")

project_number=$(gcloud config list --format='value(core.project)')
RESULT=$(gcloud certificate-manager certificates list --filter="expireTime < P15D" --format="value(name)")
if [ $? -ne 0 ];
   then 
     echo "Certificate $RESULT needs to be removed from the target_https_proxies"    
     #Identify new certificate
     newcertificate=gcloud certificate-manager certificates list --filter="expireTime > P60D" --format="value(name)"
     
     echo "$newcertificate needs to be mapped to target-https-proxy"

     oldcertificate=$(gcloud certificate-manager certificates list --filter= "expireTime < P15D" --format="value(name)")
     
     echo "Identify map $RESULT is attached too"
     
     #Identify Proxy with DNS-MAP
     
     $map_list = $(gcloud certificate-manager maps list --format 'value(name)')
     for map in $map_list 
     do 
        gcloud certificate-manager maps entries list --map $map --filter certificates="projects/$project_number/locations/global/certificates/$oldcertificate"
        if [ $? -eq 0 ]
            then
            $name=$(gcloud certificate-manager maps entries list --map dns-map --filter certificates="projects/$project_number/locations/global/certificates/$oldcertificate" --format='value(name)')

            echo "Add new certificate to Certificate Entry $name for Certificate Map $map"

            gcloud certificate-manager maps entries update $name --map $map --certificates "$oldcertificate","$newcertificate"
            
            echo "Waiting for new certificate to propagate"

            sleep 30m
            
            gcloud certificate-manager maps entries update $name --map $map --certificates "$newcertificate"

        else 
            echo "No matching certficate in $map"
        fi 
        echo 
    done 
            


     sleep 30m

     

    else

    echo "no certificate to rotate"
fi
