# Minimalistic PHP Microservice

-   [What is it?](#what-is-it)
-   [Project Stack](#project-stack)
-   [Run Project](#run-project)
    -   Clone Repository
    -   Run using Docker
    -   Check your microservice in browser
-   [Choose your extra stack](#choose-your-extra-stack)
    -   SQL Database
        -   [Why SQL database](#why-sql-database)
        -   [Why NOT SQL database](#why-not-sql-database)
-   [Extend your microservice](#extend-your-microservice)
    -   [Debug your code](#debug-your-code)
        -   [Profiler](#profiler)
            -   Install profiler
            -   Read more
    -   [Increase productivity](#increase-productivity)
        -   [Use Maker Bundle](#use-maker-bundle)
            -   Install dependencies
            -   Start using
            -   Read more
        -   [Use Api Platform](#use-api-platform)
            -   Install dependencies
            -   Read more
    -   [Unit Testing](#unit-testing)
        -   [PHPUnit](#phpunit)
            -   Install dependencies
            -   Start using PHPUnit!
            -   Read more about testing
    -   [SQL Database](#sql-database)
        -   [PostgreSQL](#postgresql)
            -   Add Postgresql Container in docker-compose.yml
            -   Add Postgresql Enviorment variables in api/.env
            -   Add dependencies in api/Dockerfile
            -   Install Doctrine Bundle in Symfony
            -   Test your connection in container
            -   Configure connection in api/config/packages/doctrine.yaml
            -   Read more about Postgresql, Doctrine and Doctrine Bundle
    -   [NoSQL Database](#nosql-database)
        -   [MongoDB](#mongodb)
            -   Add MongoDB Container in docker-compose.yml
            -   Add MongoDB Enviorment variables in api/.env
            -   Add dependencies in api/Dockerfile
            -   Install MongoDB Bundle in Symfony
            -   Fix Enviorment Variables in api/.env
            -   Configure options in config/packages/doctrine_mongodb.yaml
            -   Read more about MongoDB and Doctrine ODM
    -   [Run cron job in container](#run-cron-job-in-container)
        -   Add cron support in build (api/Dockerfile)
        -   Add your cron jobs in api/docker/php/docker-entrypoint.sh

## What is it?

This is minimalistic microservice based on PHP. The idea is to fit any requiremnts, just start from minimum and fill it with neccessary packages

## Simple Project Stack

-   PHP8.1
-   Symfony 6
-   Docker

## Run Project

Clone Repository

```
git clone https://github.com/pavelee/minimalistic-php-microservice.git && cd minimalistic-php-microservice
```

Run using Docker

```
docker-compose up -d
```

Check your microservice in browser

Go to http://localhost:3001

## Choose your extra stack

### SQL Database

#### Why SQL Database

-   Relational SQL Database will fit well mostly in any data usage scenario.
-   Strong and clear schema.
-   Optimized engine supporting joins, grouping etc.
-   It is well known among developers.
-   SQL query language is very easy to learn. It was design to be similar to natural language.

#### Why NOT SQL Database

-   You have to migrate schema during development.
-   It's harder to redact big data
-   It's harder to optimize when data set begin to be huge
-   Not design to scale horizontally
-   Vertical scalling gets expensive

## Extend your microservice

### Send an email

#### Install mailer package from Symfony

```
docker exec php composer require symfony/mailer
```

### Log in app

#### Install monolog

```
docker exec php composer require symfony/monolog-bundle
```

#### Read more

-   https://symfony.com/doc/current/logging.html

### Debug your code

#### Profiler

Profiler let you deeply analyze your request

#### Install profiler

```
docker exec php composer require --dev symfony/profiler-pack
```

#### Read more

-   https://symfony.com/doc/current/profiler.html

### Increase productivity

#### Use Maker Bundle

Maker bundle generates code to speed up your development process

Install dependencies

```
docker exec php composer require --dev symfony/maker-bundle
```

Start using

```
docker exec php bin/console make
```

Read more

-   https://symfony.com/bundles/SymfonyMakerBundle/current/index.html

#### Use Api Platform

Install dependencies

```
docker exec php composer require api
```

Read more 

- https://api-platform.com/docs

### Unit Testing

#### PHPUnit

Install dependencies

```
docker exec php composer require --dev phpunit/phpunit symfony/test-pack
```

Start using PHPUnit!

```
docker exec php bin/console ./vendor/bin/phpunit
```

Read more about testing

-   Symfony -> https://symfony.com/doc/current/testing.html
-   PHPUnit -> https://phpunit.readthedocs.io

### SQL Database

#### PostgreSQL

Add Postgresql Container in docker-compose.yml

```
services:
  postgresql:
      image: postgres:13
      env_file:
          - ./api/.env
      volumes:
          - pg-db-data:/var/lib/postgresql/data:rw

volumes:
    pg-db-data: {}
```

Add Postgresql Enviorment variables in api/.env

```
POSTGRES_PASSWORD=password
POSTGRES_USER=user
POSTGRES_DB=db
POSTGRES_VERSION=13
POSTGRES_CHARSET=UTF8
#its a name of service in docker-compose.yml
POSTGRES_HOST=postgresql
```

Add dependencies in api/Dockerfile

```
RUN apk add postgresql-dev; \
	docker-php-ext-install -j$(nproc) pdo_pgsql
```

Install Doctrine Bundle in Symfony

```
docker exec php composer require symfony/orm-pack
```

Configure connection in api/config/packages/doctrine.yaml

```
doctrine:
    dbal:
        user: '%env(resolve:POSTGRES_USER)%'
        password: '%env(resolve:POSTGRES_PASSWORD)%'
        dbname: '%env(resolve:POSTGRES_DB)%'
        host: '%env(resolve:POSTGRES_HOST)%'
        charset: '%env(resolve:POSTGRES_CHARSET)%'
        server_version: '%env(resolve:POSTGRES_VERSION)%'
        driver: 'pdo_pgsql'
```

Test your connection in container

```
docker exec php bin/console dbal:run-sql "SELECT 1"
```

Read more about Postgresql, Doctrine and Doctrine Bundle

-   Postgresql -> https://www.postgresql.org
-   Doctrine -> https://www.doctrine-project.org/projects/doctrine-orm/en/2.9/index.html
-   Doctrine Bundle in Symfony -> https://symfony.com/doc/current/doctrine.html

### NoSQL Database

#### MongoDB

Add MongoDB Container in docker-compose.yml

```
services:
  mongo:
    image: mongo:5.0
    env_file:
      - ./api/.env
    volumes:
      - mongo-db-data:/data/db

volumes:
    mongo-db-data: {}
```

Add MongoDB Enviorment variables in api/.env

```
MONGO_INITDB_ROOT_USERNAME=sfsf213fsafa
MONGO_INITDB_ROOT_PASSWORD=fsafasr121asd
```

Add dependencies in api/Dockerfile

```
RUN apk add openssl-dev && pecl install mongodb && docker-php-ext-enable mongodb
```

Install MongoDB Bundle in Symfony

```
docker exec php composer require doctrine/mongodb-odm-bundle
```

Fix Enviorment Variables in api/.env

```
MONGODB_URL=mongodb://mongo
MONGODB_DB=yourdbname
```

Configure options in config/packages/doctrine_mongodb.yaml

```
options:
    username: '%env(resolve:MONGO_INITDB_ROOT_USERNAME)%'
    password: '%env(resolve:MONGO_INITDB_ROOT_PASSWORD)%'
```

Read more about MongoDB and Doctrine ODM

-   MongoDB -> https://docs.mongodb.com
-   Doctrine ODM -> https://docs.mongodb.com

### Run cron job in container

Add cron support in build (api/Dockerfile)

```
RUN apk add dcron libcap; \
	touch /etc/crontabs/www-data; \
    chown -R www-data:www-data /etc/crontabs/www-data; \
    chown www-data:www-data /usr/sbin/crond && setcap cap_setgid=ep /usr/sbin/crond; \
	crontab /etc/crontabs/www-data;
```

Add your cron jobs in api/docker/php/docker-entrypoint.sh

```
  echo '*  *  *  *  *    /srv/api/bin/console app:your:command' >> /etc/crontabs/www-data
  echo $'\n' >> /etc/crontabs/www-data #required empty line on the end of cronjob
  crond -b -l 8 # enable cron deamon
```
