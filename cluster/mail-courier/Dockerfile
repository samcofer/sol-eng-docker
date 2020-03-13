# from https://github.com/camptocamp/docker_smtp
#
# Dockerfile for a IMAP server
#
FROM debian:stretch

ENV DEBIAN_FRONTEND noninterative

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
#RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get update && \
    apt-get install -y courier-imap && \
    mkdir -p /run/courier/authdaemon && \
    rm -rf /var/lib/apt/lists/*

# add a user 'smtp' with password : 'smtp'
RUN useradd -ms /bin/bash -p PcdO6g4gV662A smtp

# Generate script to run at startup
COPY ./start.sh /root/
RUN chmod +x /root/start.sh

# Expose the IMAP port
EXPOSE 143

CMD ["/root/start.sh"]

