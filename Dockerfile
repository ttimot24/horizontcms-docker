FROM mattrayner/lamp:latest-1804

ENV HASH baf1608c33254d00611ac1705c1d9958c817a1a33bce370c0595974b342601bd80b92a3f46067da89e3b06bff421f182

RUN apt-get update -yqq && \
    apt-get install -yqq curl mysql-client git unzip && \
    apt-get install php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl -y && \
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

RUN cd /app && git clone https://github.com/ttimot24/HorizontCMS.git && \
    cd HorizontCMS && composer install
   
CMD service mysql start && mysql -uroot -e "CREATE DATABASE IF NOT EXISTS horizontcms"

VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 80 3306
CMD ["/run.sh"] 

CMD ls -l

CMD cd /app/HorizontCMS && \
    php artisan migrate --no-interaction --force && \
    php artisan db:seed --no-interaction --force && \
    php artisan hcms:user --create-admin --name=Administrator --email=admin@admin.com --username=admin --passsword=admin
