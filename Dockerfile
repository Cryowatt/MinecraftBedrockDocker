FROM buildpack-deps AS download
ARG MINECRAFT_VERSION
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
WORKDIR /minecraft
RUN curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${MINECRAFT_VERSION}.zip -o /minecraft/bedrock-server.zip
RUN unzip /minecraft/bedrock-server.zip
RUN rm bedrock_server_realms.debug

FROM ubuntu:focal AS server
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 \
    && apt-get clean
COPY --from=download /minecraft/ /opt/minecraft/
RUN ln -s /opt/minecraft/bedrock_server /usr/local/bin/bedrock_server && \
    mkdir /var/minecraft && \
    mv /opt/minecraft/server.properties /var/minecraft/server.properties && \
    ln -s /var/minecraft/server.properties /opt/minecraft/server.properties
WORKDIR /opt/minecraft/
ENV LD_LIBRARY_PATH=/opt/minecraft/
CMD [ "bedrock_server" ]


### WINDOWS STUFF

FROM mcr.microsoft.com/powershell:nanoserver-1909 AS download-windows
ARG MINECRAFT_VERSION
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
SHELL [ "pwsh.exe", "-Command" ]
WORKDIR /Minecraft
RUN Invoke-RestMethod https://minecraft.azureedge.net/bin-win/bedrock-server-$env:MINECRAFT_VERSION.zip -OutFile /Minecraft/bedrock-server.zip -Verbose; \
    Expand-Archive /Minecraft/bedrock-server.zip -DestinationPath /Minecraft; \
    Remove-Item /Minecraft/bedrock-server.zip;


FROM mcr.microsoft.com/windows/nanoserver:1909 AS server-windows
COPY --from=download /Minecraft/ /Minecraft/
WORKDIR /Minecraft
CMD [ "bedrock_server.exe" ]
