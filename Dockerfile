FROM            debian:8

# Install basic software for server
RUN             apt-get update && \
                apt-get upgrade -y && \
                apt-get install -y \
                    wget \
                    vim \
                    git \
                    apt-transport-https \
                    lsb-release \
                    ca-certificates && \
                wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
                echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Install PHP and Apache
RUN             apt-get update && \
                apt-get install -y \
                    apache2 \
                    php7.1-cli \
                    php7.1-fpm \
                    php7.1-curl \
                    php7.1-mbstring \
                    php7.1-xml \
                    php7.1-xdebug \
                    php7.1-zip && \
                a2enmod \
                    proxy_fcgi \
                    setenvif \
                    rewrite \
                    headers && \
                a2enconf php7.1-fpm

# Override PHP setup
RUN             sed -i "s/;date.timezone =.*/date.timezone = UTC/g" /etc/php/7.1/fpm/php.ini && \
                sed -i "s/;date.timezone =.*/date.timezone = UTC/g" /etc/php/7.1/cli/php.ini && \
                sed -i "s/error_log =.*/error_log = \\/var\\/docker_stderr/g" /etc/php/7.1/fpm/php-fpm.conf && \
                sed -i "s/;catch_workers_output =.*/catch_workers_output = yes/g" /etc/php/7.1/fpm/pool.d/www.conf

# Setup Supervisord to keep both PHP and Apache daemons running
RUN             apt-get update && \
                apt-get install -y supervisor && \
                mkdir -p /var/www/web
COPY            etc/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean apt-get
RUN             apt-get clean && \
                rm -rf /var/lib/apt/lists/*

# Override Apache setup (pushes access and errors to stdout/err for pid=1, which should be the Supervisord, run by CMD)
COPY            etc/vhost/default.conf /etc/apache2/sites-enabled/000-default.conf
RUN             sed -i "s/Timeout 300/Timeout 30/g" /etc/apache2/apache2.conf &&\
                ln -sfT /proc/1/fd/1 /var/docker_stdout && \
                ln -sfT /proc/1/fd/2 /var/docker_stderr && \
                ln -sf /var/docker_stderr /var/log/apache2/error.log && \
                ln -sf /var/docker_stdout /var/log/apache2/access.log && \
                ln -sf /var/docker_stdout /var/log/apache2/other_vhosts_access.log

# Start services for Supervisord to look after
RUN             service php7.1-fpm start && \
                service apache2 start

# Install Composer
RUN             php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
                php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
                php composer-setup.php && \
                php -r "unlink('composer-setup.php');" && \
                mv composer.phar /usr/local/bin/composer

# Run server
WORKDIR         /var/www
CMD             ["/usr/bin/supervisord"]
