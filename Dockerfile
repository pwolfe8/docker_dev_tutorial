FROM ubuntu:20.04

### set your timezone here ###
ARG TIMEZONE="America/New_York"

### set default shell as bash ###
SHELL ["/bin/bash", "-c"]

### apt install prereqs ###
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=${TIMEZONE} apt install -y \
    cmake \
    gfortran \
    python3.9 \
    python3-pip \
    python3-tk \
    git

### symlink gfortran and python3 ###
RUN ln -s /usr/bin/gfortran /usr/local/bin/gfortran
RUN ln -s /usr/bin/python3 /usr/bin/python

### install python packages ###
RUN pip install \
    pytest \
    numpy \
    matplotlib \
    scipy \
    pandas

### install optional debug packages (xeyes & ping if you need them)
RUN apt install -y \
    x11-apps \
    iputils-ping \
    net-tools \
    vim

### set working directory to /root/ ###
WORKDIR /root/

# NOTE: you can save this to your docker hub and pull from there instead to reduce build time


### copy, build, & install custom code ###
COPY . ncar-glow
RUN cd ncar-glow && cmake -B build && cmake --build build
RUN pip install -e ncar-glow
# pytest runs tests that download geomagnetic indices using FTP (port 21) make sure that port is open if it's closed for some reason
RUN pytest ncar-glow

### setup bashrc to ask for your display automatically ###
RUN echo 'python selectDisplayForwardingIP.py' >> ~/.bashrc && \
    echo 'source ~/ncar-glow/change_display_var.sh' >> ~/.bashrc

# docker compose also binds the git folder to /root/ncar-glow for development
WORKDIR /root/ncar-glow/



# create user
# ARG USER=devel
# ARG PASSWORD=devel
# RUN useradd -d /home/${USER} -m -s /bin/bash -g root -G sudo ${USER}
# RUN echo "${PASSWORD}\n${PASSWORD}" | passwd ${USER}
# RUN sudo chown -R devel /home/devel
# USER ${USER}
# WORKDIR /home/${USER}
# CMD /bin/bash
