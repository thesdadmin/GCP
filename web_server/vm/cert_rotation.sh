#!/bin/bash
#ENV vars from Cloud Run 
# certificate_type (self,managed) self are user provided and managed are created by google 
# certificate_expiration
# 

if certificate_type = self
  newcertificate=gcloud compute ssl-certificates list --filter="expireTime > certificate_expiration"
  oldcertificate=gcloud certificate-manager certificates list --filter="expireTime = certificate_expiration"
  

  else 
    if certificate_type = managed
     newcertificate=gcloud certificate-manager certificates list --filter="expireTime > certificate_expiration"
     oldcertificate=gcloud certificate-manager certificates list --filter="expireTime = certificate_expiration"

     fi
fi