FROM node:14

ARG VERSION
ENV VERSION=${VERSION}

MAINTAINER Format team <innov-format@teads.tv>

ADD . /var/www
WORKDIR /var/www

RUN npm i

RUN node ./build-system/task-runner/install-amp-task-runner.js

EXPOSE 8000

CMD amp --config=prod --version_override "${VERSION}"
