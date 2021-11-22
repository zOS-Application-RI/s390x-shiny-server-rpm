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

RUN DEBIAN_FRONTEND=noninteractive yum update -y \
    && yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && dnf install -y epel-release \
    && yum install -y \ 
    python3 \
    # cmake \
    gcc \
    gcc-c++ \
    autoconf \
    automake \
    git \
    curl \
    wget \
    sudo \
    xz \
    rpm-build

## Setup R
ADD build_r.sh /tmp/
RUN cd /tmp \
    # && wget https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/R/4.1.1/build_r.sh \
    # && bash build_r.sh -y -j AdoptJDK-OpenJ9 \
    && bash build_r.sh -y 
## Build CMAKE
RUN wget http://www.cmake.org/files/v2.8/cmake-2.8.10.tar.gz \
    && tar -zxf cmake-2.8.10.tar.gz \
    && cd cmake-2.8.10 \
    && ./configure --prefix=/usr/local \
    && gmake install \
    && cmake -version

RUN git clone https://github.com/rstudio/shiny-server.git 
    
COPY install-node.sh shiny-server/external/node/

RUN shiny-server/packaging/make-package.sh
