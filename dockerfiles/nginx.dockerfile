FROM nginx:stable-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}
# ENV WORDPRESS_DB_USER=root
# ENV WORDPRESS_DB_PASSWORD=password

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system wordpress
RUN adduser -G wordpress --system -D -s /bin/sh -u ${UID} wordpress
RUN sed -i "s/user  nginx/user wordpress/g" /etc/nginx/nginx.conf

ADD .ma/nginx/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www/html