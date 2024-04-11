FROM rust:slim-bookworm as builder

RUN apt-get update
RUN apt-get install -y pkg-config
RUN apt-get install -y libssl-dev
RUN apt-get install -y libsqlite3-dev
RUN cargo install listenbrainz-mpd
RUN apt-get install -y openssl

FROM debian:bookworm-slim AS INTERM

RUN apt-get update
RUN apt-get install -y openssl
RUN apt-get install -y sqlite3
RUN rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/listenbrainz-mpd /usr/bin/listenbrainz-mpd

FROM scratch
COPY --from=INTERM / /

LABEL maintainer="GioF71"
LABEL source="https://github.com/GioF71/listenbrainz-mpd-docker"

ENV LISTENBRAINZ_TOKEN ""
ENV LISTENBRAINZ_TOKEN_FILE ""
ENV PUID ""
ENV PGID ""

VOLUME /cache

RUN mkdir -p /app/bin
COPY app/bin/run.sh /app/bin/
RUN chmod +x /app/bin/run.sh

ENTRYPOINT [ "/app/bin/run.sh" ]

