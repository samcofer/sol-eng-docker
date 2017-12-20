FROM ubuntu:16.04
#phusion/baseimage:0.9.22

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y apt-transport-https && \
	apt-get dist-upgrade -y

#RUN echo 'deb https://cran.rstudio.com/bin/linux/ubuntu xenial/' >> /etc/apt/sources.list && \
#	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \ 
#	apt-get update

# kerberos server
RUN apt-get install -y ntp krb5-admin-server krb5-kdc supervisor && \
	mkdir /var/log/supervisord

COPY kdc.conf /etc/krb5kdc/kdc.conf
COPY kadm5.acl /etc/krb5kdc/kadm5.acl
COPY krb5.conf /etc/krb5.conf

COPY ./supervisord.conf /etc/supervisord.conf

RUN chmod -R 644 /etc/krb* 
	#cp /etc/init.d/krb* /etc/my_init.d/



# when container is starting
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]


# when container is starting
#CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

#FROM centos:centos7
#
#RUN yum update -y && \
#  yum install -y \
#    gnome-keyring \
#    keyutils \
#    krb5-libs \
#    krb5-server \
#    krb5-workstation \
#    && \
#  yum clean all
#
#COPY ./krb5.conf /etc/krb5.conf
#COPY kdc.conf /var/kerberos/krb5kdc/kdc.conf
#COPY kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
#
#RUN kdb5_util create -s -P pass
#      ##systemctl start krb5kdc
#
## systemd related prep
#ENV container docker
#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;
#VOLUME [ "/sys/fs/cgroup" ]
#
#CMD ["/usr/sbin/init"]
