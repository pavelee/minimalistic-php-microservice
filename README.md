# Simple PHP Microservice

-   [What is it?](#what-is-it)
-   [Project Stack](#project-stack)
-   [Extend your microservice](#extend-your-microservice)
    -   [NoSQL Database - MongoDB](#nosql-database---mongodb)

## What is it?

This is minimalistic microservice based on PHP. The idea is to fit any requiremnts, just start from minimum and add extra neccessary packaged

## Simple Project Stack

-   PHP8
-   Symfony 5.3
-   Docker

## Extend your microservice

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

2. Add dependecies in api/Dockerfile

```
RUN apk add openssl-dev && pecl install mongodb && docker-php-ext-enable mongodb
```

3. Install MongoDB Bundle in Symfony

```
composer require doctrine/mongodb-odm-bundle
```

4. Fix Enviorment Variables in api/.env

```
MONGODB_URL=mongodb://mongo
MONGODB_DB=yourdbname
```

5. Add options with creditentials in config/packages/doctrine_mongodb.yaml
```
options:
    username: '%env(resolve:MONGO_INITDB_ROOT_USERNAME)%'
    password: '%env(resolve:MONGO_INITDB_ROOT_PASSWORD)%'
```
