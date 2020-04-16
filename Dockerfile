# gitbox with gitlist v.0.5.0
# https://github.com/nmarus/docker-gitbox
# Nicholas Marus <nmarus@gmail.com>

FROM alpine

# Setup Container
VOLUME ["/repos"]
VOLUME ["/ng-auth"]
EXPOSE 80

# Setup Environment Variables
ENV ADMIN="gitadmin"

RUN apk --update add git less nginx-full fcgiwrap && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*



# Update, Install Prerequisites, Clean Up APT
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
#    apt-get -y install git wget nginx-full php5-fpm fcgiwrap apache2-utils && \
#    apt-get clean

# Setup Container User
RUN useradd -M -s /bin/false git --uid 1000


# Setup nginx fcgi services to run as user git, group git
RUN sed -i 's/FCGI_USER="www-data"/FCGI_USER="git"/g' /etc/init.d/fcgiwrap && \
    sed -i 's/FCGI_GROUP="www-data"/FCGI_GROUP="git"/g' /etc/init.d/fcgiwrap && \
    sed -i 's/FCGI_SOCKET_OWNER="www-data"/FCGI_SOCKET_OWNER="git"/g' /etc/init.d/fcgiwrap && \
    sed -i 's/FCGI_SOCKET_GROUP="www-data"/FCGI_SOCKET_GROUP="git"/g' /etc/init.d/fcgiwrap

# Create config files for container startup and nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Create config files for container
COPY config.ini /var/www/gitlist/config.ini
COPY repo-admin.sh /usr/local/bin/repo-admin
COPY ng-auth.sh /usr/local/bin/ng-auth
RUN chmod +x /usr/local/bin/repo-admin
RUN chmod +x /usr/local/bin/ng-auth

# Create start.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Startup
CMD ["/start.sh"]
