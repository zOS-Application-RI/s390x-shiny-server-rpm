FROM registry.redhat.io/ubi8/ubi
ARG CRAN
SHELL ["/bin/bash", "-c"]
## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
# RUN DEBIAN_FRONTEND=noninteractive yum -y update \
#     && ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime \
#     && yum install -y locales tzdata 
# RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
#     && locale-gen en_US.utf8 \
#     && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive \
    # LC_ALL=en_US.UTF-8 \
    # LC_CTYPE=en_US.UTF-8 \
    # LANG=en_US.UTF-8 \
    CRAN=${CRAN:-https://cran.rstudio.com}

RUN DEBIAN_FRONTEND=noninteractive yum update \
    && yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && dnf install epel-release \
    && yum update -y \
    && yum install -y \ 
    python3 \
    cmake \
    gcc \
    g++ \
    git \
    r-base-dev \
    curl \
    wget


RUN git clone https://github.com/rstudio/shiny-server.git 
    
COPY install-node.sh shiny-server/external/node/

RUN /home/linux1/shiny-server/packaging/make-package.sh
