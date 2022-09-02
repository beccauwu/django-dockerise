# django-dockerise

## 1. Introduction

This is a little collection for those wanting to quickly and easily deploy their django app on a server with docker.
It comes prepacked with all the necessary files to deploy an app.

### Files Included:

    src
    ├── docker-compose.prod.yml     # Full docker-compose file
    ├── app                         # Files to be copied into project root
    │   ├── Dockerfile.prod         # Main Dockerfile
    │   └── entrypoint.prod.sh      # Entrypoint executed from compose
    └── nginx                       # Nginx files
        ├── Dockerfile              # Nginx Donckerfile
        └── nginx.conf              # Nginx configuration

## 2. Features

* Dockerise a Django app to run with Gunicorn
* PostgreSQL server installed automatically
* pgAdmin to be able to browse database
* App served through nginx on ports 80:80
* Easily create backups of your database with run.sh
* Easily restore your old database(s) from a .sql file

## 3. Limitations:

* Currently the configuration only exposes port 80, so SSL has to be acheived through a 3rd party proxy (I've used Cloudflare)
* Nginx routing to pgAdmin doesn't work currently, it can be accessed by manually going to port 5050 on the server

## 4. How to use:

1. Copy folders and run.sh into same directory as django root folder like so:

        .
        ├── /app           # Your django app folder
        │   └── manage.py 
        ├── /src 
        ├── /bin 
        └── run.sh
2. Change settings.py as follows:
```
> app/main/settings.py

DEBUG = False
ALLOWED_HOSTS = os.environ.get('DJANGO_ALLOWED_HOSTS').split(' ')
CSRF_TRUSTED_ORIGINS = os.environ.get('DJANGO_TRUSTED_ORIGINS').split(' ')

[...]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('SQL_DATABASE'),
        'USER': os.environ.get('SQL_USER'),
        'PASSWORD': os.environ.get('SQL_PASSWORD'),
        'HOST': os.environ.get('SQL_HOST'),
        'PORT': os.environ.get('SQL_PORT'),
    }
}
```
3. Execute run.sh
4. Choose 3
5. Fill in all the necessary info, this will create env files in the .env folder in root
6. At the end choose build now
7. Build script will run, here you'll have a chance to easily edit the configuration files
8. Script will copy the files into right directories and start build/run the container
9.  Done! Now all you need to do is point your domain to your server address

