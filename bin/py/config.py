import os
from random import choice
import shutil
from getpass import getpass
from string import Template, ascii_letters, digits
from pathlib import Path
BASE = Path(__file__).resolve().parent.parent.parent
LIB = os.path.join(BASE, 'src', 'lib')
created = ''
class TemplateFile:
    def __init__(self, src):
        self.src = src
        self.filename = os.path.basename(src)

    def write(self, dest, **kwargs):
        global created
        if not os.path.exists(dest):
            os.makedirs(dest)
        with open(self.src, 'r') as f:
            file = os.path.join(dest, self.filename)
            template = Template(f.read())
            result = template.substitute(**kwargs)
        with open(file, 'w') as f:
            print(f'Writing {self.filename} to {dest}...')
            f.write(result)
            created += f' {file}'
            print("Done.")

def get_random_string():
    print("Generating secret key...")
    return ''.join(choice(ascii_letters + digits) for _ in range(50))

def file_copy(app_folder):
    print("Copying main dockerfile...")
    shutil.copy2(os.path.join(LIB, 'Dockerfile.prod'), os.path.join(BASE, app_folder))
    print("Copying entrypoint...")
    shutil.copy2(os.path.join(LIB, 'entrypoint.prod.sh'), os.path.join(BASE, app_folder))
    if not os.path.exists(os.path.join(BASE, 'nginx')):
        os.makedirs(os.path.join(BASE, 'nginx'))
    print("Copying nginx dockerfile...")
    shutil.copy2(os.path.join(LIB, 'Dockerfile'), os.path.join(BASE , 'nginx'))
    print("Copying nginx.conf...")
    shutil.copy2(os.path.join(LIB, 'nginx.conf'), os.path.join(BASE, 'nginx'))
    print("\nDone.")
    while True:
        src_del = input("Delete source files? (y/n) ")
        if src_del.lower() == 'y':
            print("Deleting source files...")
            shutil.rmtree(os.path.join(BASE, 'src'))
            print("Done.")
            break
        elif src_del.lower() == 'n':
            print("Keeping source files.")
            break
        else:
            print("Please answer with y or n.")
            continue

def compose():
    d_compose = TemplateFile(os.path.join(LIB, 'docker-compose.prod.yml'))
    app_folder = input("Please enter the name of the project folder (where manage.py is located): ")
    
    d_compose.write(
        os.path.join(BASE),
        app_folder=app_folder
        )
    return app_folder

def prod(db_name, user, password):
    prod_file = TemplateFile(os.path.join(LIB, '.prod.env'))
    print("By default, the first host will be the trusted origin.")
    while True:
        hosts = input("Allowed hosts separated by a space (example.domain.com 127.0.0.1):\n")
        if not hosts:
            print("You need to specify at least one host.")
            continue
        break
    first = hosts.split(" ")[0]
    while True:
        answer = input(f'\nSet trusted origin as https://{first} (y/n)? ')
        if 'y' == answer.lower():
            trusted = f'https://{first}'
            break
        elif 'n' == answer.lower():
            trusted = input("Trusted origin: ")
            break
        else:
            print("Please answer with y or n.")
            continue
    if not 'https://' in trusted:
        trusted = f'https://{trusted}'
    while True:
        makesecret = input("\nAutomatically generate secret key (y/n)? ")
        if makesecret.lower() == 'y':
            secret = get_random_string()
            break
        elif makesecret.lower() == 'n':
            secret = getpass("Secret key: ")
            break
        else:
            print("Please answer with y or n.")
            continue
    prod_file.write(
        os.path.join(BASE, '.env'),
        trusted=trusted,
        secret=secret,
        hosts=hosts,
        sqldb=db_name,
        sqluser=user,
        sqlpw=password
        )

def db():
    db_file = TemplateFile(os.path.join(LIB, '.db.env'))
    print("First, let's configure the database.\n")
    user = input("\nDatabase user (default root): \n")
    if not user:
        user = 'root'
    password = getpass("\nDatabase password (default root): \n")
    if not password:
        password = 'root'
    else:
        while True:
            password2 = getpass("\nConfirm password: \n")
            if password != password2:
                print("Passwords don't match.")
                print("Please try again.")
                continue
            break
    db_name = input("\nDatabase name (default postgres): \n")
    if not db_name:
        db_name = 'postgres'
    db_file.write(
        os.path.join(BASE, '.env'),
        user=user,
        password=password,
        db_name=db_name
    )
    return db_name, user, password

def main():
    data = db()
    prod(data[0], data[1], data[2])
    app_folder = compose()
    file_copy(app_folder)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborting...")
        print("Checking for created files...")
        for file in created.split(' '):
            if os.path.isfile(file):
                delete = input(f"Delete file {file} (y/n)? ")
                if delete.lower() == 'y':
                    shutil.rmtree(os.path.join(BASE, '.env'))
                    print("Deleted.")
                else:
                    print("Not deleted.")
        print("Exiting...")
