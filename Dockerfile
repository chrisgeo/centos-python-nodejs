FROM centos:latest
ENV PYTHONBUFFERED 1
ENV PYTHONPATH /app/djvenom
ENV AES_KEYS_PATH /app/aes.json
ENV LANG en_US.UTF-8
ENV PYTHON_VERSION 2.7.10

# add epel repo
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

# update
RUN yum -y update

# install base packages
RUN yum -y groupinstall "Development Tools"
RUN yum -y install erlang gcc gcc-c++ kernel-devel-`uname -r` make perl sqlite-devel
RUN yum -y install bzip2 bzip2-devel zlib-devel
RUN yum -y install ncurses-devel readline-devel tk-devel
RUN yum -y install net-tools nfs-utils openssl-devel
RUN yum -y install git screen tmux wget zsh

# fix paths
RUN echo 'Defaults  secure_path=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' >> /etc/sudoers.d

# install rsyslog v7
RUN wget http://rpms.adiscon.com/v7-stable/rsyslog.repo -O /etc/yum.repos.d/rsyslog.repo
RUN yum -y install rsyslog rsyslog-docs

# install python 2.7
RUN wget -O Python-${PYTHON_VERSION}.tar.xz http://python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && tar -xf Python-${PYTHON_VERSION}.tar.xz;
RUN cd Python-${PYTHON_VERSION} && ./configure --prefix=/usr/local && make && make altinstall;
RUN rm -rf Python*
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python

# bootstrap python setuptools and distribute
RUN wget -O get_pip.py https://bootstrap.pypa.io/get-pip.py
RUN /usr/local/bin/python get_pip.py
RUN rm -rf get_pip.py

RUN cd / \
    && mkdir -p /usr/src/node \ 
    && wget 'https://nodejs.org/dist/v0.12.6/node-v0.12.6.tar.gz' \
    && tar --strip-components 1 -xzvf node-v* -C /usr/src/node/ \
    && rm node-v*.tar.gz \
    && cd /usr/src/node/ \
    && pwd && ls -lta \
    && ./configure \ 
    && make \
    && make install \
    && ldconfig \
    && rm -rf /usr/src/node \
    && yum clean all

CMD ["python2"]
