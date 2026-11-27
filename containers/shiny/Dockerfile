# Based upon the Shiny dockerfile from rocker-org https://rocker-project.org/images/versioned/shiny.html
# OpenShift run user fixes from https://github.com/Duke-GCB/openshift-shiny
# Timezone set to UTC-7 for British Columbia
# syntax=docker/dockerfile:1

FROM ubuntu:26.04

ENV R_VERSION="4.6.2"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC-7"

RUN apt-get update && apt-get install -y curl
#Get all the sources we use and put them in the same hiearchiy as the rocker dockerfie
RUN <<EOF
mkdir assets
cd assets
curl -LJO https://raw.githubusercontent.com/bcgov/openshift_shinyhub/tree/main/containers/shiny/shiny-server.conf
curl -LJO https://raw.githubusercontent.com/bcgov/openshift_shinyhub/tree/main/containers/shiny/shiny-server.sh
curl -LJO https://raw.githubusercontent.com/bcgov/openshift_shinyhub/tree/main/containers/shiny/fix-username.sh
chmod +x *.sh
cd ..
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

RUN /rocker_scripts/setup_R.sh

# ENV S6_VERSION="v2.1.0.2"
ENV SHINY_SERVER_VERSION="latest"
ENV PANDOC_VERSION="default"

RUN /rocker_scripts/install_shiny_server.sh

#----------
# Cleanup demo application reports.
#----------

# RUN <<EOF
# apt-get autoremove --purge -y
# cd /srv/shiny-server
# rm -rf *
# EOF

# RUN <<EOF
# mv /assets/shiny-server.conf /etc/shiny-server/shiny-server.conf
# mv /assets/shiny-server.sh /usr/bin/shiny-server.sh
# mv /assets/fix-username.sh /usr/bin/fix-username.sh
# EOF

#----------
# Do file group and permissions touchups
#----------

# Grant group 0 (OpenShift's arbitrary UID group) ownership and write permissions
RUN chmod 0775 /usr/bin/shiny-server.sh && \
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

RUN <<EOF
usermod -g 0 shiny
EOF

# Create a non-root user for local Docker testing (OpenShift will ignore the UID)
# RUN useradd -u 1001 -r -g 0 -d /app -s /sbin/nologin -c "Default Application User" appuser && \
    # Assign ownership to group 0 (root group) and match group permissions to user permissions
#    chgrp -R 0 /app && \
#    chmod -R g=u /app

# Specify the numeric UID (OpenShift requires a numeric UID, not a username, to pass validation)
# USER 1001

# Bypass s6 (/init) and launch Shiny Server directly
ENTRYPOINT []

#CMD ["/usr/bin/shiny-server.sh"]
CMD ["/bin/bash", "-c", "sleep infinity"]