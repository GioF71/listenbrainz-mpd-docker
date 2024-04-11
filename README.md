# listenbrainz-mpd-docker

A docker image for [listenbrainz-mpd](https://codeberg.org/elomatreb/listenbrainz-mpd)

## Build

From the repository directory, you can build the image using the following:

```code
docker build . -t giof71/listenbrainz-mpd
```

## Configuration

### Environment Variables

VARIABLE|DESCRIPTION
:---|:---
LISTENBRAINZ_TOKEN|Listenbrainz token, alternative to `LISTENBRAINZ_TOKEN_FILE`
LISTENBRAINZ_TOKEN_FILE|Listenbrainz token file, alternative to `LISTENBRAINZ_TOKEN`
ENABLE_CACHE|Enables submission caching (YES/NO, Y/N, True/False case insensitive)
CACHE_DIRECTORY|Submission caching directory, defaults to `/cache`
CACHE_FILE|Submission caching file, defaults to `cache.sqlite3`
MPD_ADDRESS|ip and port of mpd, defaults to `localhost:6600`
MPD_PASSWORD|MPD password, alternative to `MPD_PASSWORD_FILE`
MPD_PASSWORD_FILE|MPD password file, alternative to `MPD_PASSWORD`
PUID|Run the application using that uid, defaults to `1000`
PGID|Run the application using that gid, defaults to `1000`

### Volumes

VOLUME|DESCRIPTION
:---|:---
/cache|Submission cache directory

## Examples

