FROM centos:latest
MAINTAINER Yi Ou email: ouyi@gmx.de

# Update the image with the latest packages (recommended)
RUN yum update -y && yum clean all

RUN yum install -y epel-release man which tree bash-completion vim-enhanced git rpm-build tmux pdsh && yum clean all

RUN yum -y install python-pip python-paramiko && yum clean all

RUN pip install radon pylint pep8 ansible

COPY gitconfig  /root/.gitconfig
COPY vimrc /root/.vimrc
COPY tmux.conf /root/.tmux.conf

COPY bashrc /tmp/bashrc
RUN cat /tmp/bashrc >> /root/.bashrc  && rm -f /tmp/bashrc

WORKDIR /root