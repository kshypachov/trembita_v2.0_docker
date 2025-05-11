FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

LABEL authors="Kirill Shypachov @kshypachov"

ARG REPO_KEY=http://192.168.99.189/uxp-ua-repo-key.gpg

RUN apt-get update  \
    && apt-get install -y equivs  \
    && equivs-control fake-systemd \
    && sed -i 's/^Package:.*/Package: systemd/' fake-systemd \
    && echo 'Version: 255.0\nArchitecture: all\nDescription: dummy systemd for containers' >> fake-systemd \
    && equivs-build fake-systemd \
    && dpkg -i systemd_255.0_all.deb

RUN apt-get update
RUN apt-get install -y nano

RUN apt-get -qq update && apt-get -qq --no-install-recommends -y install \
      locales ca-certificates perl bzip2 libc6-dev lsb-release gnupg2 \
      ca-certificates gnupg supervisor net-tools iproute2 locales \
      rlwrap ca-certificates-java debconf-utils \
      crudini adduser expect curl rsyslog dpkg-dev \
    && echo "LC_ALL=en_US.UTF-8" >>/etc/environment \
    && locale-gen en_US.UTF-8 \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

#RUN sed -i 's/^[A-Za-z0-9]/#&/' /etc/apt/sources.list \
#    && rm -rf /etc/apt/sources.list.d/*
RUN echo "deb http://192.168.99.189/uxp jammy main" | tee -a /etc/apt/sources.list
RUN echo "deb http://192.168.99.189/dependencies2 jammy main" | tee -a /etc/apt/sources.list
RUN echo "deb http://192.168.99.189/minio jammy main" | tee -a /etc/apt/sources.list
RUN echo "deb http://192.168.99.189/elasticsearch/8.x jammy main" | tee -a /etc/apt/sources.list
RUN echo "deb http://192.168.99.189/zabbix/6.0 jammy main" | tee -a /etc/apt/sources.list
RUN echo "deb http://192.168.99.189/graylog jammy main" | tee -a /etc/apt/sources.list

ADD ["$REPO_KEY","/tmp/repokey.gpg"]
RUN apt-key add '/tmp/repokey.gpg'
RUN echo "LC_ALL=en_US.UTF-8" >>/etc/environment
RUN locale-gen en_US.UTF-8

RUN echo "uxp-proxy uxp-common/username string uxpadmin" | debconf-set-selections
RUN echo "uxp-identity-provider-rest-api  uxp-identity-provider/password  password uxpadminp" | debconf-set-selections
RUN useradd -m uxpadmin -s /usr/sbin/nologin -p '$6$7rx.CcTn$lkhsqW3zu6BrKbnQbOMaIFsZWv.DgH5LxtsXuxDftj8yF2e/KgxTOUQFozkYfcf1H.HSyxEtECMF8P7vy4M1b/'

RUN apt-get -qq update \
    && apt-get -y --no-install-recommends install ssl-cert \
    && apt-get -y --no-install-recommends install postgresql-16 --no-install-recommends \
    && apt-get -y --no-install-recommends install nginx \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

RUN printf  '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
    && printf  "#!/bin/sh\nexit 0\n" > /usr/sbin/service && chmod +x /usr/sbin/service \
    && printf '#!/bin/sh\nexit 0\n' > /bin/systemctl && chmod +x /bin/systemctl

RUN pg_ctlcluster 16 main start \
    && nginx -g 'daemon on;' \
#    && sleep 5 \
    && apt-get -qq update \
    && apt-get -qq -y --no-install-recommends install uxp-securityserver-trembita  \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* \
    && wait

COPY ss_trembita.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

#VOLUME ["/etc/uxp", "/var/lib/uxp", "/var/lib/postgresql/16/main/", "/var/log/uxp/"]
VOLUME ["/etc/uxp", "/var/lib/uxp"]
EXPOSE 4000 5500 5577 5599 443 80

#RUN apt-get -qq update \
#    && apt-get -y --no-install-recommends install uxp-securityserver-trembita \
#    && apt-get clean  \
#    && rm -rf /var/lib/apt/lists/*