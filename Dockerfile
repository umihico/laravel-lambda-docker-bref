FROM bref/php-80-fpm
COPY . /var/task
CMD [ "public/index.php" ]
