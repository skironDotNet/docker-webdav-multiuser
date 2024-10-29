# Docker WebDav with automatic multi user support

This is simple purpose docker container. It does not support SSL and is meant to be used only behind reverse proxy such as NPM or Nginx that supports SSL.

The whole Apache configuration is created during the start of the container based on `users.pwd` expected in `/conf` location of the container, so the `users.pwd` should be mounded from host.   

## How to use it

Copy the files to your server or clone the git repository. Run `./build.sh` to buld the image.  
Use attached docker-compose.yml in `compose` folder and customize it if needed.

Before running the container, you need to define users and their passwords. Each user has it's own folder and can access only own folder.

In compose folder you can see the ready example file, but for the sake of the complete documentation.
1. Create a file `users.pwd`
2. From the host run `htpasswd users.pwd userName`, you'll be asked to enter the password for that user.
3. Mount the file in your docker-compose.yml as
```
    volumes:
      - ./users.pwd:/conf/users.pwd # Mount the users.pwd file.
      - ./data:/users   # Mount the local `data` directory for user folders
```
4. Run the container via `docker compose up -d`

Based on declared user names in `users.pwd`, each user will have its own WebDav location as `http://localhost:8080/userName/`

If you proxy it with SSL as domain.com then each user will have its own location as `https://domain.com/userName/`

Removing a user from `users.pwd` and restarting the container will remove the access for that user but the data folder will be preserved. The access can be restored back by adding the user back and restarting the container.

### Serve static web content in addition to WebDav server 

In case you want to host some static web page from the root location like `https://domain.com/`  
(the `index.html` will be loaded automatically as default in Apache)

Include env variable in docker-compose.yml
```
    environment:
      - EnableWWW=true
```


In your compose file under `volumes:` section, add: 
```
     - ./www:/www
```
where `www` is your folder with static html files and/or images. It works for me without `chown -R www-data:www-data www` but that's probabaly because of 744 mask on the files, so "public" can read. If you can't see the content then run `chown -R www-data:www-data www`