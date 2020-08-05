ARG RSP_VERSION=1.2.5033-1
FROM rstudio/r-session-complete:bionic-${RSP_VERSION}

COPY ./stdin_echo.py /stdin_echo.py

RUN mv /usr/lib/rstudio-server/bin/rserver-launcher /usr/lib/rstudio-server/bin/rserver-launcher-orig && \
	apt-get update && \
	apt-get install -y vim cron nano tcpdump
  #pip install asyncio mitmproxy && \
  #yum update && yum install -y tcpdump

COPY ./r-session-debug/entrypoint.sh /usr/lib/rstudio-server/bin/rserver-launcher

