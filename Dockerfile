FROM centos:latest
MAINTAINER Yi Ou

# Make man pages work
RUN sed -i 's/tsflags=nodocs//g' /etc/yum.conf

# Update the image with the latest packages (recommended)
RUN yum update -y && yum clean all

# Command-line tools and config files
RUN yum install -y epel-release man which tree bash-completion vim-enhanced git rpm-build tmux pdsh bc wget telnet net-tools lsof socat && yum clean all

COPY config/gitconfig  /root/.gitconfig
COPY config/vimrc /root/.vimrc
COPY config/tmux.conf /root/.tmux.conf
COPY config/bashrc /tmp/bashrc
RUN cat /tmp/bashrc >> /root/.bashrc  && rm -f /tmp/bashrc

# Install python stuff
RUN yum -y install python-pip python-paramiko && yum clean all

RUN pip install radon pylint pep8 ansible awscli datadog

# Install nodejs
RUN curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -

RUN yum -y install nodejs && yum clean all

# Install java and maven
ENV JAVA_VERSION 8u112
ENV JAVA_BUILD_NUM b15

RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD_NUM/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm

RUN yum -y install /tmp/jdk-8-linux-x64.rpm && rm -f /tmp/jdk-8-linux-x64.rpm

# For some reason, the alternatives install does not work for jar and javaws
#RUN alternatives --install /usr/bin/java java /usr/java/latest/bin/java 200000 && alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
COPY config/java_env.sh /etc/profile.d/java_env.sh

ENV MAVEN_VERSION 3.3.9

RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

COPY config/maven_env.sh /etc/profile.d/maven_env.sh

# The following installs openjdk as dependency, which is not what I want
#RUN yum -y install maven && yum clean all

# Install antlr4
ENV ANTLR_JAR antlr-4.5.3-complete.jar
RUN curl http://www.antlr.org/download/${ANTLR_JAR} -o /usr/local/lib/${ANTLR_JAR}
COPY config/antlr4.sh /etc/profile.d/antlr4.sh

# Install packer
RUN wget https://releases.hashicorp.com/packer/0.10.2/packer_0.10.2_linux_amd64.zip -O /tmp/packer.zip
RUN unzip /tmp/packer.zip -d /usr/local/packer && ln -s /usr/local/packer/packer /usr/local/bin/packer.io && rm -f /tmp/packer.zip

# Required by GUI applications
RUN yum install -y libXext libXrender libXtst && yum clean all

WORKDIR /root
