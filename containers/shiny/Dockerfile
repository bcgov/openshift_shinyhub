# Shiny Server for running on OpenShift.
# Based upon the Shiny dockerfile from rocker-org https://rocker-project.org/images/versioned/shiny.html
# OpenShift run user fixes from https://github.com/Duke-GCB/openshift-shiny
# Timezone set to UTC-7 for British Columbia
# syntax=docker/dockerfile:1

FROM ubuntu:26.04
RUN mkdir app
WORKDIR /app
# on docker/podman we need to use COPY . /app/
# on openshift we need to use copy /containers/shiny/* /app/
COPY /containers/shiny/* /app/
#COPY . /app/

#----------
# Set the environment variables
#----------
ENV R_VERSION="4.6.2"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC-7"
ENV CRAN="https://p3m.dev/cran/__linux__/resolute/latest"
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
# ENV S6_VERSION="v2.1.0.2"
ENV SHINY_SERVER_VERSION="latest"
ENV PANDOC_VERSION="default"
ENV TMPDIR=/tmp
ENV HOME=/tmp

#----------
# Update the environment
# Install curl
# Reconfigure locales
#----------
RUN <<EOF
apt-get update
apt-get install -y curl
apt-get install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
EOF

#----------
# Stage the rocker shiny install and configuration scripts.
#----------
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
ln -s /app/rocker_scripts /rocker_scripts
EOF

#----------
# Run the rocker install scripts.
#----------
RUN /app/rocker_scripts/install_R_source.sh
RUN /app/rocker_scripts/setup_R.sh
RUN /app/rocker_scripts/install_shiny_server.sh

#----------
# Move the Duke-GCB files
#----------
RUN <<EOF
chmod +x /app/*.sh
mv /app/shiny-server.conf /etc/shiny-server/shiny-server.conf
mv /app/shiny-server.sh /usr/bin/shiny-server.sh
mv /app/fix-username.sh /usr/bin/fix-username.sh
EOF

#----------
# Do file group and permissions touchups
# Grant group 0 (OpenShift's arbitrary UID group) ownership and write permissions
#----------
RUN chgrp -R 0 /opt/pandoc \
               /opt/shiny-server \
               /usr/local/lib/R \
               /var/log/shiny-server \
               /var/lib/shiny-server \
               /srv/shiny-server \
               /etc/shiny-server \
               /usr/bin/shiny-server \
               /etc/passwd \
               /usr/bin/fix-username.sh \
               /usr/bin/shiny-server.sh && \
    chmod -R g=u /etc/passwd \
                 /opt/pandoc \
                 /opt/shiny-server \
                 /usr/local/lib/R \
                 /var/log/shiny-server \
                 /var/lib/shiny-server \
                 /srv/shiny-server \
                 /etc/shiny-server \
                 /usr/bin/shiny-server \
                 /usr/bin/fix-username.sh \
                 /usr/bin/shiny-server.sh

#----------
# Change the shiny user group to 0
#----------
RUN <<EOF
usermod -g 0 shiny
EOF

#----------
# Expose the port we are going to use.
#----------
EXPOSE 3838

#----------
# Run the shiny server
#----------
CMD ["/usr/bin/shiny-server.sh"]