FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

COPY ./oracle-client /tmp

RUN apt-get update -yqq && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install tools
    openssl \
    nano \
    ghostscript \
    iputils-ping \
    locales \
    rlwrap \
    make \
    unzip \
    zip \
    tar \
    ca-certificates \
    software-properties-common \
    # Install PHP5.6
    && add-apt-repository ppa:ondrej/php -y && \
    apt-get install -yq --no-install-recommends \
    php5.6 \
    libapache2-mod-php5.6 \
    php5.6-cli \
    php5.6-json \
    php5.6-curl \
    php5.6-fpm \
    php5.6-dev \
    php5.6-gd \
    php5.6-ldap \
    php5.6-mbstring \
    php5.6-bcmath \
    php5.6-mysql \
    php5.6-soap \
    php5.6-sqlite3 \
    php5.6-xml \
    php5.6-zip \
    php5.6-intl \
    php-pear \
    libldap2-dev \
    libaio1 \
    libaio-dev \
    php5.6-xdebug \
    && apt-get clean && \
    # Install Oracle Client
    cd /opt &&\
    mkdir oracle &&\
    mv /tmp/instantclient* /opt/oracle/ &&\
    cd /opt/oracle/ &&\
    unzip instantclient-basic-linux.x64-12.2.0.1.0.zip &&\
    unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip &&\
    unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip &&\
    cd /opt/oracle/instantclient_12_2/ &&\
    ln -s libclntsh.so.12.1 libclntsh.so &&\
    echo "/opt/oracle/instantclient_12_2/" >> /etc/ld.so.conf.d/oracle.conf &&\
    ldconfig &&\
    echo 'export ORACLE_HOME=/opt/oracle' >> ~/.bashrc &&\
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/oracle/instantclient_12_2' >> ~/.bashrc &&\
    echo 'PATH=$PATH:/opt/oracle/instantclient_12_2' >> ~/.bashrc &&\
    echo "alias sqlplus='/usr/bin/rlwrap -m /opt/oracle/instantclient_12_2/sqlplus'" >> ~/.bashrc &&\
    cd /opt/oracle &&\
    pecl download oci8-2.0.12 &&\
    tar -xzvf oci8-2.0.12.tgz &&\
    cd oci8-2.0.12 &&\
    phpize &&\
    ./configure --with-oci8=instantclient,/opt/oracle/instantclient_12_2/ &&\
    make install &&\
    echo 'instantclient,/opt/oracle/instantclient_12_2' | pecl install oci8-2.0.12

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8

# Configure PHP for My Site
COPY my-site.ini /etc/php/5.6/mods-available/
COPY xdebug.ini /etc/php/5.6/mods-available/xdebug.ini
RUN phpenmod my-site
# Configure apache for My Site
RUN a2enmod rewrite expires proxy_fcgi setenvif
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername
# Configure vhost for My Site
COPY my-site.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite my-site.conf

RUN ln -s /etc/apache2/mods-available/ssl.load  /etc/apache2/mods-enabled/ssl.load
RUN mkdir -p /etc/apache2/ssl
COPY localhost+2.pem /etc/apache2/ssl/
COPY localhost+2-key.pem /etc/apache2/ssl/

EXPOSE 80 443

WORKDIR /var/www

# RUN rm index.html

CMD apachectl -D FOREGROUND
