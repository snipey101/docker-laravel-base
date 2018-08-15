##### WEBAPP BUILD #####
FROM croudtech/webapp:2.0 AS webapp
ARG ssh_key

RUN mkdir /root/.ssh
RUN touch /root/.ssh/config
RUN touch /root/.ssh/id_rsa

RUN echo ${ssh_key} | base64 --decode >> /root/.ssh/id_rsa

RUN chown root:root -R /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa

RUN echo "    IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config
RUN echo "    StrictHostKeyChecking no" >> /root/.ssh/config

RUN mkdir -p /var/www/app_tmp

WORKDIR /var/www/app_tmp

COPY ./api/composer.json ./
COPY ./api/composer.lock ./

RUN composer install  --no-scripts --no-autoloader --no-dev

WORKDIR /var/www/app

ENV WEBAPP_ROOT /var/www/app
ENV DOC_ROOT /var/www/app/public
ENV CONFIG_DIR /var/www/app/server_config
ENV NGINX_HOSTNAME app
ENV APP_LOG=errorlog

ENV CRON_TABS_LOCATION /usr/share/docker_build/crontablsdocker-machine env -u
COPY ./docker_build /usr/share/docker_build
COPY ./src ./

RUN rsync -ah /var/www/app_tmp/* ${WEBAPP_ROOT}/
RUN rm -fr /var/www/app_tmp

RUN composer dump-autoload --optimize

RUN chown -R www-data:www-data ./
