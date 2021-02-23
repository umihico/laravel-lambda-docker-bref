FROM bref/php-80-fpm
RUN curl -s https://getcomposer.org/installer | php
COPY . /var/task
CMD [ "public/index.php" ]
