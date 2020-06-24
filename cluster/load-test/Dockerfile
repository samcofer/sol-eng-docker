FROM rstudio/r-base:3.6.3-bionic

RUN apt-get update && apt-get install -y default-jre-headless && \
	curl -o shinycannon.deb https://s3.amazonaws.com/rstudio-shinycannon-build/2019-11-22-20:24:21_1.0.0-9b22a92/deb/shinycannon_1.0.0-9b22a92_amd64.deb && \
	dpkg -i shinycannon.deb

ENTRYPOINT [ "/usr/local/bin/shinycannon" ]
