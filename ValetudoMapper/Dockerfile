ARG BUILD_FROM
FROM homeassistant/armv7-base:3.10 AS BUILD

ENV LANG C.UTF-8
ENV VALETUDOMAPPER_VERSION 0.3.0
ENV COMMIT_SHA '02655ed8f2e1c81d6b1798fd63c9b7c0ef70e382'

RUN apk add --no-cache git=2.22.0-r0 npm=10.16.3-r0
# hadolint ignore=DL3003
RUN git clone https://github.com/rand256/valetudo-mapper.git -b master /app && \
    cd app && git checkout $COMMIT_SHA

WORKDIR /app
RUN npm install

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
