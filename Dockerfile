FROM steamcmd/steamcmd:latest

# change this to your timezone
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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

ARG user
ARG password

RUN steamcmd +@sSteamCmdForcePlatformType windows +login ${user} ${password} +download_depot 526870 526871 7399828939544997957 +quit

WORKDIR /root/.steam/steamcmd/linux32/steamapps/content/app_526870/depot_526871/
# Start the game, get it to populate ini files
RUN wine start FactoryGame.exe -nosteamclient -nullrhi -nosplash -nosound && sleep 5

# Force map load in config (todo: use a magic python script to handle this)
RUN echo "[/Script/EngineSettings.GameMapsSettings]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "GameDefaultMap=/Game/FactoryGame/Map/GameLevel01/Persistent_Level" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "LocalMapOptions=?sessionName=ServerSave?Visibility=SV_FriendsOnly?loadgame=ServerSave?listen?bUseIpSockets?name=Host" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini

# probably add network settings
RUN echo "[/Script/Engine.Player]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "ConfiguredInternetSpeed=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "ConfiguredLanSpeed=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "[/Script/OnlineSubsystemUtils.IpNetDriver]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "MaxClientRate=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "MaxInternetClientRate=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "[/Script/SocketSubsystemEpic.EpicNetDriver]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "MaxClientRate=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN echo "MaxInternetClientRate=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini

RUN echo "[/Script/Engine.GameNetworkManager]" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Game.ini
RUN echo "TotalNetBandwidth=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Game.ini
RUN echo "MaxDynamicBandwidth=104857600" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Game.ini
RUN echo "MinDynamicBandwidth=10485760" >> ~/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Game.ini

RUN apt install lsof -y

ENTRYPOINT wine start FactoryGame.exe -nosteamclient -nullrhi -nosplash -nosound && /bin/bash

# Sample run command - mount the save folder, expose port 7777
# docker run --mount type=bind,source=D:\dev\satisfactory-docker\SaveGames,target="/root/.wine/drive_c/users/root/Local Settings/Application Data/FactoryGame/Saved/SaveGames" -it -p7777:7777 test
# How to view logs
# vim /root/.wine/drive_c/users/root/Local\ Settings/Application\ Data/FactoryGame/Saved/Logs/FactoryGame.log


#docker run --mount type=bind,source=/home/sfserver/satisfactory-docker/SaveGames,target="/root/.wine/drive_c/users/root/Local Settings/Application Data/FactoryGame/Saved/SaveGames" \
#    -it -p7777:7777/udp satisfactory
