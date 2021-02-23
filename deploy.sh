#!/bin/bash
set -euxo pipefail

ACCOUNTID=$(aws sts get-caller-identity --query 'Account'| xargs)
REGION=$(aws configure get region)
APP_NAME=larademo
ECR_TAG=$ACCOUNTID.dkr.ecr.$REGION.amazonaws.com/$APP_NAME:latest
$(aws ecr get-login --no-include-email)
docker build . -t $APP_NAME
docker tag $APP_NAME $ECR_TAG
docker push $ECR_TAG
sls deploy --region $REGION --tag $ECR_TAG
