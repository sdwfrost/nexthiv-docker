# Use phusion/baseimage as base image
FROM phusion/baseimage:0.9.19

# Set environment variables the phusion way
RUN echo en_US.UTF-8 > /etc/container_environment/LANGUAGE
RUN echo en_US.UTF-8 > /etc/container_environment/LANG
RUN echo en_US.UTF-8 > /etc/container_environment/LC_ALL
RUN echo UTF-8 > /etc/container_environment/PYTHONIOENCODING

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

MAINTAINER Simon Frost <sdwfrost@gmail.com>

## Set a default user. Available via runtime flag `--user docker`
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& mkdir /home/docker/programs \
	&& addgroup docker staff

RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
 	build-essential \
 	python3-dev \
	git \
	wget \
	cmake

## Add RethinkDB repository

RUN echo "deb http://download.rethinkdb.com/apt xenial main" > /etc/apt/sources.list.d/rethinkdb.list
RUN wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends rethinkdb

# Install the recent pip release
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
	python3 get-pip.py && \
	rm get-pip.py	&& \
	# Install nexthiv
	pip3 install git+https://github.com/sdwfrost/nexthiv@master

# Install IQ-TREE
RUN cd /home/docker/programs && \
	git clone https://github.com/Cibiv/IQ-TREE.git && \
	cd IQ-TREE && \
	mkdir build && \
	cd build && \
	cmake -DIQTREE_FLAGS=omp .. && \
	make && \
	cp iqtree-omp /usr/local/bin && \
	rm -rf /home/docker/programs/IQ-TREE

# Install MAFFT
RUN cd /home/docker/programs && \
	wget http://mafft.cbrc.jp/alignment/software/mafft-7.305-without-extensions-src.tgz && \
	tar zxvf mafft-7.305-without-extensions-src.tgz && \
	cd mafft-7.305-without-extensions/core && \
	make clean && \
	make && \
	make install && \
	rm /home/docker/programs/mafft-7.305-without-extensions-src.tgz && \
	rm -rf /home/docker/programs/mafft-7.305-without-extensions

# Install TN93
RUN cd /home/docker/programs && \
  git clone https://github.com/veg/tn93 && \
  cd tn93 && \
  cmake . && \
  make install && \
  rm -rf /home/docker/programs/tn93

#VOLUME ["data"]
