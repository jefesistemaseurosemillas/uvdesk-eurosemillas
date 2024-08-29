FROM ubuntu:latest
LABEL maintainer="akshay.kumar758@webkul.com"

ENV GOSU_VERSION 1.11

# Install base packages and dependencies
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        apache2 \
        mysql-server \
        php7.4 \
        libapache2-mod-php7.4 \
        php7.4-common \
        php7.4-xml \
        php7.4-imap \
        php7.4-mysql \
        php7.4-mailparse \
        gnupg2 \
        dirmngr \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the user "uvdesk" without password and home directory
RUN useradd -m -d /home/uvdesk -s /bin/bash uvdesk

# Copy configuration files
COPY ./.docker/config/apache2/env /etc/apache2/envvars
COPY ./.docker/config/apache2/httpd.conf /etc/apache2/apache2.conf
COPY ./.docker/config/apache2/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./.docker/bash/uvdesk-entrypoint.sh /usr/local/bin/
COPY . /var/www/uvdesk/

# Set up Apache, Gosu, and Composer
RUN a2enmod php7.4 rewrite \
    && chmod +x /usr/local/bin/uvdesk-entrypoint.sh \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && gpgconf --kill all \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && wget -O /usr/local/bin/composer.php "https://getcomposer.org/installer" \
    && actualSig="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && currentSig="$(shasum -a 384 /usr/local/bin/composer.php | awk '{print $1}')" \
    && [ "$currentSig" = "$actualSig" ] \
    && php /usr/local/bin/composer.php --quiet --filename=/usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && chown -R uvdesk:uvdesk /var/www \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc /usr/local/bin/composer.php /var/www/bin /var/www/html /var/www/uvdesk/.docker

# Set the working directory
WORKDIR /var/www

# Set the entrypoint and default command
ENTRYPOINT ["uvdesk-entrypoint.sh"]
CMD ["/bin/bash"]