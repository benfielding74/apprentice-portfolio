#!/bin/bash

# variables
AWS_PROFILE=vscode
AWS_REGION=eu-west-2
APEX_DOMAIN=bfieldingapprenticeportfolio.me

#terraform
export TF_VAR_region=$AWS_REGION
export TF_VAR_profile=$AWS_PROFILE
export TF_VAR_apex_domain=$APEX_DOMAIN

#directory containing script file
dir="$(cd "$(dirname "0")"; pwd)"
cd "$dir"

create-certificate() {
    cd "$dir"
    log create certificate
    CERTIFICATE_ARN=$(aws acm request-certificate \
        --domain-name $APEX_DOMAIN \
        --subject-alternative-names *.$APEX_DOMAIN \
        --validation-method DNS \
        --query CertificateArn \
        --region us-east-1 \
        --profile $AWS_PROFILE \
        --output text)
    log CERTIFICATE_ARN $CERTIFICATE_ARN

    RESOURCE_RECORD=$(aws acm describe-certificate \
        --certificate-arn $CERTIFICATE_ARN \
        --query 'Certificate.DomainValidationOptions[0].ResourceRecord' \
        --region us-east-1 \
        --profile $AWS_PROFILE)

    CNAME_NAME=$(echo "$RESOURCE_RECORD" | jq --raw-output '.Name')
    log CNAME_NAME $CNAME_NAME

    CNAME_VALUE=$(echo "$RESOURCE_RECORD" | jq --raw-output '.Value')
    log CNAME_VALUE $CNAME_VALUE

    log create CNAME.json
    cat > CNAME.json << EOF
{
  "Comment": " ",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "$CNAME_NAME",
        "Type": "CNAME",
        "TTL": 600,
        "ResourceRecords": [
          {
            "Value": "$CNAME_VALUE"
          }
        ]
      }
    }
  ]
}
EOF

    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
        --dns-name $APEX_DOMAIN \
        --profile $AWS_PROFILE \
        --query 'HostedZones[0].Id' \
        --output text)
    log HOSTED_ZONE_ID $HOSTED_ZONE_ID

    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch file://CNAME.json \
        --profile $AWS_PROFILE \
        1>/dev/null

    CERTIFICATE_STATUS=$(aws acm describe-certificate \
        --certificate-arn $CERTIFICATE_ARN \
        --query 'Certificate.Status' \
        --region us-east-1 \
        --profile $AWS_PROFILE \
        --output text)
    log CERTIFICATE_STATUS $CERTIFICATE_STATUS

    log wait certificate-validated
    aws acm wait certificate-validated \
        --certificate-arn $CERTIFICATE_ARN \
        --region us-east-1 \
        --profile $AWS_PROFILE

    CERTIFICATE_STATUS=$(aws acm describe-certificate \
        --certificate-arn $CERTIFICATE_ARN \
        --query 'Certificate.Status' \
        --region us-east-1 \
        --profile $AWS_PROFILE \
        --output text)
    log CERTIFICATE_STATUS $CERTIFICATE_STATUS
}
