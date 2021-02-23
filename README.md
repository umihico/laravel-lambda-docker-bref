# Delpoy Laravel on AWS Lambda with Docker using Bref

### Step 1. Create your project

```
curl -s https://laravel.build/larademo | bash
```

### Step 2. install requirements and generate serverless.yml

```bash
cd larademo
./vendor/bin/sail up -d
./vendor/bin/sail composer require bref/bref bref/laravel-bridge
./vendor/bin/sail php artisan vendor:publish --tag=serverless-config
./vendor/bin/sail down
```

### Step 3. Create Dockerfile and deploy.sh, and modify serverless.yml

```Dockerfile:Dockerfile
FROM bref/php-80-fpm
COPY . /var/task
CMD [ "public/index.php" ]
```

```bash:deploy.sh
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
```

```diff:serverless.yml
service: laravel

provider:
    name: aws
    # The AWS region in which to deploy (us-east-1 is the default)
    region: {opt:region, us-east-1}
    # The stage of the application, e.g. dev, production, staging… ('dev' is the default)
    stage: dev
    runtime: provided.al2

package:
    # Directories to exclude from deployment
    exclude:
        - node_modules/**
        - public/storage
        - resources/assets/**
        - storage/**
        - tests/**

functions:
    # This function runs the Laravel website/API
    web:
        image: ${opt:tag}
        events:
            -   httpApi: '*'
```


### Step 4. Deploy!

```bash
aws ecr create-repository --repository-name larademo # run this only once
sh deploy.sh # this build, push and deploy
```

### References

- https://aws.amazon.com/jp/blogs/compute/building-php-lambda-functions-with-docker-container-images/
- https://bref.sh/docs/frameworks/laravel.html
- https://laravel.com/docs/8.x/installation
- https://laravel.com/docs/8.x/sail#introduction
- https://please-sleep.cou929.nu/bash-strict-mode.html
