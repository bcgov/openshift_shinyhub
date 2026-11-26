# Based upon the Shiny dockerfile from rocker-org https://rocker-project.org/images/versioned/shiny.html
# OpenShift run user fixes from https://github.com/Duke-GCB/openshift-shiny
# Timezone set to UTC-7 for British Columbia
# syntax=docker/dockerfile:1

FROM docker.io/library/ubuntu:resolute

ENV R_VERSION="4.6.2"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC-7"

RUN apt-get update && apt-get install -y curl
#Get all the sources we use and put them in the same hiearchiy as the rocker dockerfie
RUN <<EOF
mkdir rocker_scripts
cd rocker_scripts
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/install_R_source.sh
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/setup_R.sh
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/install_shiny_server.sh
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/install_s6init.sh 
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/install_pandoc.sh
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/init_set_env.sh
chmod +x *
mkdir bin
cd bin
curl -LJO https://raw.githubusercontent.com/rocker-org/rocker-versioned2/refs/heads/master/scripts/bin/install2.R
chmod +x *
EOF

RUN /rocker_scripts/install_R_source.sh
ENV CRAN="https://p3m.dev/cran/__linux__/resolute/latest"
ENV LANG=en_US.UTF-8

RUN <<EOF
if grep -q "1000" /etc/passwd; then
    userdel --remove "$(id -un 1000)";
fi
/rocker_scripts/setup_R.sh
EOF

# ENV S6_VERSION="v2.1.0.2"
ENV SHINY_SERVER_VERSION="latest"
ENV PANDOC_VERSION="default"

RUN /rocker_scripts/install_shiny_server.sh

#Do some cleanup
# RUN <<EOF
# apt-get autoremove --purge -y
# cd /srv/shiny-server
# rm -rf *
# EOF

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY fix-username.sh /usr/bin/fix-username.sh

#----------
# Do file group and permissions touchups
# The "shiny" account is remapped to the OpenShift-assigned UID at start (fix-username.sh)
#----------

# Grant group 0 (OpenShift's arbitrary UID group) ownership and write permissions
RUN sed -i 's/\r$//' /usr/bin/shiny-server.sh && \
    chmod 0775 /usr/bin/shiny-server.sh && \
    chgrp -R 0 /opt/pandoc \
               /opt/shiny-server \
               /usr/local/lib/R \
               /var/log/shiny-server \
               /var/lib/shiny-server \
               /srv/shiny-server \
               /etc/shiny-server \
               /usr/bin/shiny-server \
               /etc/passwd \
               /usr/bin/shiny-server.sh \
               /usr/bin/fix-username.sh && \
    chmod -R g=u /etc/passwd \
                 /opt/pandoc \
                 /opt/shiny-server \
                 /usr/local/lib/R \
                 /var/log/shiny-server \
                 /var/lib/shiny-server \
                 /srv/shiny-server \
                 /etc/shiny-server \
                 /usr/bin/shiny-server \
                 /usr/bin/shiny-server.sh \
                 /usr/bin/fix-username.sh
# Ensure R's temporary directory is writable by any UID
ENV TMPDIR=/tmp

EXPOSE 3838

ENV HOME=/tmp

# OpenShift's restricted SCC replaces this with the project's assigned UID (group 0) at runtime;
# fix-username.sh then maps that UID to the "shiny" account
USER Shiny

# Bypass s6 (/init) and launch Shiny Server directly
ENTRYPOINT []
RUN ECHO $USER
CMD ["/usr/bin/shiny-server.sh"]