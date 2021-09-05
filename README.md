# Satisfactory Docker Server

## Config

1. Set the `TZ`-Environment variable in the `Dockerfile` to your local timezone (default `Europe/London`)
2. Copy your local `config.vdf` file (`<Steam_Installation_Folder>/config/config.vdf`) in the `satisfactory-docker` directory
3. Get your steamguard key via email with `steamcmd +login <steam_username> <steam_password>`

## Build

`docker build -t satisfactory:<tag> . --build-arg user=<steam_username> --build-arg password=<steam_password> --build-arg guard_code=<steam_guard_code>`

## Run

`docker run -d -p 7777:7777 satisfactory:latest`
