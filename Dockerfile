FROM rc2k7/steamcmd:latest
MAINTAINER Ruben Castaneda <rubennc1994@gmail.com>

# Build Arguments
ARG DST_HOME
ENV DST_HOME ${DST_HOME:-"/opt/dst"}

ARG CLUSTER_PATH
ENV CLUSTER_PATH ${CLUSTER_PATH:-"/data/dst/cluster"}

# Install Dependencies
RUN set -x \
	
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		lib32stdc++6 \
		libcurl4-gnutls-dev:i386

# Install Don't Starve Together Server
RUN set -x \
	&& mkdir -p $DST_HOME \
	&& chown $STEAM_USER:$STEAM_USER $DST_HOME \
	&& sync \
	&& gosu $STEAM_USER steamcmd \
		+login anonymous \
		+force_install_dir $DST_HOME \
		+app_update 343050 validate\
		+quit

# Cleanup
RUN set -x \
	&& rm -rf $STEAM_HOME/Steam/logs $STEAM_HOME/Steam/appcache/httpcache \
	&& find $STEAM_HOME/package -type f ! -name "steam_cmd_linux.installed" ! -name "steam_cmd_linux.manifest" -delete \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Copy Scripts
COPY scripts/* /usr/local/bin/

# Copy Entrypoint
COPY docker-entrypoint.sh /


# Set Entrypoint
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["dst-server"]