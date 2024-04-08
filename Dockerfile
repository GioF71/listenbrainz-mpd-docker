FROM rust:slim-bookworm as builder

RUN apt-get update
RUN apt-get install -y pkg-config
RUN apt-get install -y libssl-dev
RUN apt-get install -y libsqlite3-dev
RUN cargo install listenbrainz-mpd

FROM debian:bookworm-slim

#RUN apt-get update
#RUN apt-get install -y extra-runtime-dependencies
# RUN rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/listenbrainz-mpd /usr/bin/listenbrainz-mpd
CMD ["listenbrainz-mpd"]
