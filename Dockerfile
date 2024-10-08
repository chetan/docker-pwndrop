# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.20 AS buildstage

# build variables
ARG PWNDROP_RELEASE

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    build-base \
    go \
    git

RUN \
echo "**** fetch source code ****" && \
  cd /tmp && \
  git clone https://github.com/SygniaLabs/pwndrop.git && \
  echo "**** compile pwndrop  ****" && \
  cd /tmp/pwndrop && \
  make build && \
  mkdir -p /app/pwndrop && \
  cp -a ./build/pwndrop /app/pwndrop/pwndrop && \
  cp -r ./www /app/pwndrop/admin && \
  chmod 755 /app/pwndrop/pwndrop

############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PWNDROP_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# add pwndrop
COPY --from=buildstage /app/pwndrop/ /app/pwndrop/

RUN \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version

# add local files
COPY /root /

# ports and volumes
EXPOSE 8080 4443
