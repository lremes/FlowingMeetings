apk add --no-cache bash curl tar nodejs tzdata git file

apk --update add --virtual build_deps \
    build-base libc-dev linux-headers \
    openssl-dev sqlite-dev libxml2-dev libxslt-dev curl-dev yarn && rm -rf /var/cache/apk/*
