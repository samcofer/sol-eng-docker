FROM compose_launcher-rsp:6

COPY ./launcher/run /etc/services.d/rstudio/run
COPY ./launcher/finish /etc/services.d/rstudio/finish

# adhoc fixes to make it work...
RUN mkdir -p /home/users && \
	 chmod -R 777 /home/users && \
	chmod -R 777 /etc/services.d/rstudio

CMD ["/init"]
