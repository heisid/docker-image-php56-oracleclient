# Development LARAVEL 5 enviroment

Forked from https://github.com/jjuanrivvera99/docker-image-usc with downgraded PHP version to PHP 5.6 and additional xdebug.

- Ubuntu 18.04 + Apache 2 + Oracle Client 12.2 + PHP 5.6 + xdebug 2.5.5 (Port 9003)
- Apache document root '/var/www/public'



### Build

```bash
docker build -t laravel5-oracle .
```



### Docker Compose File

##### Example

`docker-compose.yml`  in project root directory:

    version: '3'
    
    services:
      web:
        container_name: laravel-oracle
        image: laravel5-oracle:latest
        ports:
          - "80:80"
        volumes:
          - "./:/var/www

Run `docker-compose up`

Go to http://localhost

Note to myself, don't forget to: 

- `chmod 777 -R storage bootstrap public` (or it won't render to browser - Err 500)

- in PhpStorm, set:  Debug port and path mapping (or it won't stop at breakpoints)
