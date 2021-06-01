FROM node:14

MAINTAINER Format team <innov-format@teads.tv>

ADD . /var/www
WORKDIR /var/www

RUN npm i gulp
RUN amp build


EXPOSE 8000

CMD amp serve
