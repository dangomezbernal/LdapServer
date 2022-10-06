# ldapserver 2022
FROM debian:latest
LABEL author="@dan ASIX-M06"
LABEL subject="ldapserver 2022"
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install procps iproute2 tree nmap vim iputils-ping slapd ldap-utils
RUN mkdir /opt/docker
WORKDIR /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh
CMD /opt/docker/startup.sh
EXPOSE 389
