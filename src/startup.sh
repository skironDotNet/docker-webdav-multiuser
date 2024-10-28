#!/bin/sh

# Check if the authentication file exists
if [ ! -f /conf/users.pwd ]; then
    echo "Error: /conf/users.pwd file is missing. Ensure you mount the 'users.pwd' file at /conf in the container."
    exit 1
fi

# Check if the users.pwd file contains at least one user
if ! grep -q '^[^#]' /conf/users.pwd; then
    echo "Error: /conf/users.pwd file is empty or contains no valid users. Ensure it has at least one user entry."
    exit 1
fi

# Ensure DavLock file exists in the persistent /users directory
touch /users/DavLock
chown www-data:www-data /users/DavLock

# Parse each user in the users.pwd file and set up directories and configs
while IFS=: read -r user _; do
    # Create a directory for each user
    user_dir="/users/$user"
    mkdir -p "$user_dir"
    chown www-data:www-data "$user_dir"

    # Generate a configuration for each user based on the template
    user_conf="/usr/local/apache2/conf/extra/webdav_${user}.conf"
    sed "s/USERNAME_PLACEHOLDER/$user/g" /usr/local/apache2/conf/extra/webdav_template.conf > "$user_conf"
    echo "Include $user_conf" >> /usr/local/apache2/conf/httpd.conf
done < /conf/users.pwd

# Remove the default DocumentRoot section in httpd.conf to not host anything from the root location
sed -i '/DocumentRoot "\/usr\/local\/apache2\/htdocs"/,/<\/Directory>/d' /usr/local/apache2/conf/httpd.conf

# Start Apache in the foreground
exec httpd -D FOREGROUND

