# Use the official httpd Docker image
FROM httpd:latest

# Install apache2-utils for htpasswd management
RUN apt-get update && apt-get install -y apache2-utils

# Uncomment WebDAV LoadModule directives in httpd.conf
RUN sed -i 's/^#LoadModule dav_module/LoadModule dav_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^#LoadModule dav_fs_module/LoadModule dav_fs_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^#LoadModule dav_lock_module/LoadModule dav_lock_module/' /usr/local/apache2/conf/httpd.conf

# Add DavLockDB directive to ensure persistence of locks in /users
RUN echo "DavLockDB /users/DavLock" >> /usr/local/apache2/conf/httpd.conf

# Copy the WebDAV template and startup script
COPY ./webdav_template.conf /usr/local/apache2/conf/extra/webdav_template.conf
COPY ./startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose HTTP port
EXPOSE 80

# Use the startup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["httpd-foreground"]

