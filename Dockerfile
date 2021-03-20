FROM steamcmd/steamcmd:latest

ARG user

RUN apt update
# todo: remove sound/graphics from install?
# libglapi-mesa
# libgl1-mesa-dri
# libllvm10?? not needed because we shouldn't compile shaders?
RUN apt install wine-stable -y
RUN apt install libfreetype6 -y
RUN apt install python3 -y
RUN apt install tmux -y
RUN apt install vim -y
RUN dpkg --add-architecture i386
RUN apt install libfreetype6:i386 -y

# Copy the login details
COPY config.vdf ./.steam/config/config.vdf

# steamcmd has a bug where it won't download other branches if the OS is forced!
# pulled from here
# https://steamdb.info/app/526870/depots/?branch=experimental
RUN steamcmd +@sSteamCmdForcePlatformType windows +login ${user} +download_depot 526870 526871 7399828939544997957 +quit


WORKDIR /root/.steam/steamcmd/linux32/steamapps/content/app_526870/depot_526871/
# Start the game, get it to populate ini files
RUN wine start FactoryGame.exe -nosteamclient -nullrhi -nosplash -nosound && sleep 5

# Force map load in config (todo: use a magic python script to handle this)
RUN echo "[/Script/EngineSettings.GameMapsSettings]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "GameDefaultMap=/Game/FactoryGame/Map/GameLevel01/Persistent_Level" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "LocalMapOptions=?sessionName=ServerSave?Visibility=SV_FriendsOnly?loadgame=ServerSave?listen?bUseIpSockets?name=Host" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini

# expose the server port
EXPOSE 7777-7827/udp

# Actually start the server
#RUN wine start FactoryGame.exe -nosteamclient -nullrhi -nosplash -nosound

ENTRYPOINT wine start FactoryGame.exe -nosteamclient -nullrhi -nosplash -nosound && /bin/bash

# download_depot 526870 526871 7399828939544997957	
# ~/.steam/steamcmd/linux32/steamapps/content/app_526870/depot_526871
# vim ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Logs/FactoryGame.log