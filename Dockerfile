FROM bytesized/base
MAINTAINER maran@bytesized-hosting.com

# package version
ARG MEDIAINF_VER="0.7.88"

# install runtime packages
RUN \
 apk add --no-cache \
	ca-certificates \
	curl \
	fcgi \
	ffmpeg \
	geoip \
	gzip \
	nginx \
	rtorrent \
	screen \
	tar \
	unrar \
	unzip \
	wget \
	zip

RUN \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	php7 \
	php7-cgi \
	php7-fpm \
	php7-json  \
	php7-pear

RUN \
# install build packages
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	cppunit-dev \
	curl-dev \
	file \
	g++ \
	gcc \
	libtool \
	make \
	ncurses-dev \
	openssl-dev

RUN \
# install webui
 mkdir -p \
	/usr/share/webapps/rutorrent \
	/defaults/rutorrent-conf && \
 curl -o \
 /tmp/rutorrent.tar.gz -L \
	"https://github.com/Novik/ruTorrent/archive/master.tar.gz" && \
 tar xf \
 /tmp/rutorrent.tar.gz -C \
	/usr/share/webapps/rutorrent --strip-components=1 && \
 mv /usr/share/webapps/rutorrent/conf/* \
	/defaults/rutorrent-conf/ && \
 rm -rf \
	/defaults/rutorrent-conf/users

RUN \
# compile mediainfo packages
 curl -o \
 /tmp/libmediainfo.tar.gz -L \
	"http://mediaarea.net/download/binary/libmediainfo0/${MEDIAINF_VER}/MediaInfo_DLL_${MEDIAINF_VER}_GNU_FromSource.tar.gz" && \
 curl -o \
 /tmp/mediainfo.tar.gz -L \
	"http://mediaarea.net/download/binary/mediainfo/${MEDIAINF_VER}/MediaInfo_CLI_${MEDIAINF_VER}_GNU_FromSource.tar.gz" && \
 mkdir -p \
	/tmp/libmediainfo \
	/tmp/mediainfo && \
 tar xf /tmp/libmediainfo.tar.gz -C \
	/tmp/libmediainfo --strip-components=1 && \
 tar xf /tmp/mediainfo.tar.gz -C \
	/tmp/mediainfo --strip-components=1 && \

 cd /tmp/libmediainfo && \
	./SO_Compile.sh && \
 cd /tmp/libmediainfo/ZenLib/Project/GNU/Library && \
	make install && \
 cd /tmp/libmediainfo/MediaInfoLib/Project/GNU/Library && \
	make install && \
 cd /tmp/mediainfo && \
	./CLI_Compile.sh && \
 cd /tmp/mediainfo/MediaInfo/Project/GNU/CLI && \
	make install

# ports and volumes
EXPOSE 80 55555 6112

# add local files
COPY static/ /

VOLUME /config /data
