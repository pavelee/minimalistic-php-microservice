# Simple PHP Microservice

-   [What is it?](#what-is-it)
-   [Project Stack](#project-stack)
-   [Extend your microservice](#extend-your-microservice)
    -   [Unit Testing - PHPUnit](#unit-testing---phpunit)
    -   [SQL Database - PostgreSQL](#sql-database---postgresql)
    -   [NoSQL Database - MongoDB](#nosql-database---mongodb)
    -   [Add cron job in container](#add-cron-job-in-container)

## What is it?

This is minimalistic microservice based on PHP. The idea is to fit any requiremnts, just start from minimum and fill it with neccessary packages

## Simple Project Stack

-   PHP8
-   Symfony 5.3
-   Docker

## Extend your microservice

### Unit Testing - PHPUnit

1. Install PHPUnit and symfony dependencies

```
composer require --dev phpunit/phpunit symfony/test-pack
```

2. Start using PHPUnit! Just run:

```
./vendor/bin/phpunit
```

3. Read more about testing:

-   Symfony -> https://symfony.com/doc/current/testing.html
-   PHPUnit -> https://phpunit.readthedocs.io

### SQL Database - PostgreSQL

1. Add Postgresql Container in docker-compose.yml

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

2. Add Postgresql Enviorment variables in api/.env

```
POSTGRES_PASSWORD=password
POSTGRES_USER=user
POSTGRES_DB=db
POSTGRES_VERSION=13
POSTGRES_CHARSET=UTF8
#its a name of service in docker-compose.yml
POSTGRES_HOST=postgresql
```

3. Add dependencies in api/Dockerfile

```
RUN apk add postgresql-dev; \
	docker-php-ext-install -j$(nproc) pdo_pgsql
```

4. Install Doctrine Bundle in Symfony

```
docker exec php composer require symfony/orm-pack
```

5. Configure connection in api/config/packages/doctrine.yaml

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

6. Test your connection in container

```
docker exec php bin/console dbal:run-sql "SELECT 1"
```

7. Read more about Postgresql, Doctrine and Doctrine Bundle:
* Postgresql -> https://www.postgresql.org
* Doctrine -> https://www.doctrine-project.org/projects/doctrine-orm/en/2.9/index.html
* Doctrine Bundle in Symfony -> https://symfony.com/doc/current/doctrine.html

### NoSQL Database - MongoDB

1. Add MongoDB Container in docker-compose.yml

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

2. Add MongoDB Enviorment variables in api/.env

```
MONGO_INITDB_ROOT_USERNAME=sfsf213fsafa
MONGO_INITDB_ROOT_PASSWORD=fsafasr121asd
```

2. Add dependencies in api/Dockerfile

```
RUN apk add openssl-dev && pecl install mongodb && docker-php-ext-enable mongodb
```

3. Install MongoDB Bundle in Symfony

```
docker exec php composer require doctrine/mongodb-odm-bundle
```

4. Fix Enviorment Variables in api/.env

```
MONGODB_URL=mongodb://mongo
MONGODB_DB=yourdbname
```

5. Configure options in config/packages/doctrine_mongodb.yaml

```
options:
    username: '%env(resolve:MONGO_INITDB_ROOT_USERNAME)%'
    password: '%env(resolve:MONGO_INITDB_ROOT_PASSWORD)%'
```

6. Read more about MongoDB and Doctrine ODM
* MongoDB -> https://docs.mongodb.com
* Doctrine ODM -> https://docs.mongodb.com

### Add cron job in container 

1. Add cron support in build (api/Dockerfile)

```
RUN apk add dcron libcap; \
	touch /etc/crontabs/www-data; \
    chown -R www-data:www-data /etc/crontabs/www-data; \
    chown www-data:www-data /usr/sbin/crond && setcap cap_setgid=ep /usr/sbin/crond; \
	crontab /etc/crontabs/www-data;
```

2. Add your cron jobs in api/docker/php/docker-entrypoint.sh

```
  echo '*  *  *  *  *    /srv/api/bin/console app:your:command' >> /etc/crontabs/www-data
  echo $'\n' >> /etc/crontabs/www-data #required empty line on the end of cronjob
  crond -b -l 8 # enable cron deamon
```
