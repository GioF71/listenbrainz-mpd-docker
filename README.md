# listenbrainz-mpd-docker

A docker image for [listenbrainz-mpd](https://codeberg.org/elomatreb/listenbrainz-mpd), available for amd64, armv7 and arm64v8 platforms.  
A big thank you goes to the author, who also very quickly solved two issues that have probably gone unnoticed in normal use, but that I encountered while building this docker image.   

## Links

REPOSITORY TYPE|LINK
:---|:---
Git Repository|[GitHub](https://github.com/GioF71/listenbrainz-mpd-docker)
Docker Images|[Docker Hub](https://hub.docker.com/repository/docker/giof71/listenbrainz-mpd)


## Build

From the repository directory, you can build your own image using the following:

```code
docker build . -t giof71/listenbrainz-mpd
```

Please note that this will take a while, because the code will be compiled by [cargo](https://doc.rust-lang.org/cargo/).  

## Configuration

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
LISTENBRAINZ_TOKEN|Listenbrainz token, alternative to `LISTENBRAINZ_TOKEN_FILE`
LISTENBRAINZ_TOKEN_FILE|Listenbrainz token file, alternative to `LISTENBRAINZ_TOKEN`
ENABLE_CACHE|Enables submission caching (YES/NO, Y/N, True/False, case insensitive)
CACHE_DIRECTORY|Submission caching directory, defaults to `/cache`
CACHE_FILE|Submission caching file, defaults to `cache.sqlite3`
MPD_ADDRESS|ip/hostname and port of mpd, defaults to `localhost:6600`
MPD_PASSWORD|MPD password, alternative to `MPD_PASSWORD_FILE`
MPD_PASSWORD_FILE|MPD password file, alternative to `MPD_PASSWORD`
LISTENBRAINZ_MPD_LOG|Log level (trace,debug,info,warn,error,off)
GENRE_AS_FOLKSONOMY|Submit genre tags on the played songs as folksonomy tags
GENRE_SEPARATOR|Split genres at the given separator character, defaults to `;`
PUID|Run the application using that uid, defaults to `1000`
PGID|Run the application using that gid, defaults to `1000`

### Volumes

VOLUME|DESCRIPTION
:---|:---
/cache|Submission cache directory

## Examples

### Compose file

```text
---
version: '3.3'

services:
  lb-d10-vanilla:
    image: giof71/listenbrainz-mpd
    container_name: lb-d10-vanilla
    network_mode: host
    user: "${PUID:-1000}:${PGID:-1000}"
    environment:
      - MPD_ADDRESS=localhost:6600
      - LISTENBRAINZ_TOKEN=your-listenbrainz-token
    restart: unless-stopped
```

Please note that the fact you need `network_mode: host` depends on how this container can reach the target mpd.  
If you have set a docker network for mpd, you can avoid using host networking, but you will have to specify `MPD_ADDRESS` accordingly.  
