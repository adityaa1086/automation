FROM node:14.15-alpine

ARG N8N_VERSION=0.121.0

# Update everything and install needed dependencies
RUN apk add --update graphicsmagick tzdata git tini su-exec

# # Set a custom user to not have n8n run as root
USER root

# Install n8n and the also temporary all the packages
# it needs to build it correctly.
RUN apk --update add --virtual build-dependencies python build-base ca-certificates && \
	npm_config_user=root npm install -g full-icu n8n@${N8N_VERSION} && \
	apk del build-dependencies

# Install fonts
RUN apk --no-cache add --virtual fonts msttcorefonts-installer fontconfig && \
	update-ms-fonts && \
	fc-cache -f && \
	apk del fonts && \
	find  /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \;

ENV NODE_ICU_DATA /usr/local/lib/node_modules/full-icu

# specify working directory
WORKDIR /data

# copy start script to container
COPY ./start.sh /

# make the script executable
RUN chmod +x /start.sh

# define execution entrypoint
CMD ["/start.sh"]
