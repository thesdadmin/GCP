#!/bin/bash

set -euox pipefall
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




      #Filter certficated list by certificates expiring by less that 15 days. The output is just the certificate name

RESULT=gcloud compute ssl-certificates list --filter="expireTime < P15D" --format="value(name)"

if [$RESULT -ne $null];
      then 
      old_certificate=$(gcloud compute ssl-certificates list --filter="expireTime < P15D" --format="value(name)")

      echo "$old_certificate needs to removed from target_https_proxies"

      new_certificate = $(gcloud compute ssl-certificates list --filter="expireTime > P30D" --format="value(name)")
    
      #to filter by certificate expiration date and domain name
      # gcloud certificate-manager certificates list --filter="expireTime > P30D and managed.domains = 'SOMEDOMAIN'" --format="value(name)"
      
      
      $old_link = $(gcloud compute ssl-certificates list --filter="expireTime < P15D" --format="value(selfLink)")

      
      gcloud compute target-https-proxies list --filter ssl_certificates="$old_link"
      
      gcloud compute target-ssl-proxies update --ssl-certificates '$old_certificate','$new_certificate'
      
      sleep 2m

      gcloud compute target-ssl-proxies SOME_PROXY_NAME update --ssl-certificates '$new_certificate'
  
  

else 
  echo "No certficates to rotate"  
fi