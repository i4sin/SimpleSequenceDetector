FROM ubuntu:focal as base
FROM questasim-10.7c-base:0.1.0

COPY --from=base / /

ENV PATH=$PATH:/opt/questasim/questasim/linux_x86_64
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/questasim/questasim/linux_x86_64
ENV LM_LICENSE_FILE=/opt/questasim/license.dat

RUN apt-get update && apt-get install -y \
    libx11-6 libxrender1 libxtst6 libxi6 libxft2 python3 python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install vunit
RUN echo $( \
        unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy && \
        pip3 install pysocks==1.7.1 \
    ) && \
    pip3 install  edalize==0.4.0 && \
    pip3 install  fusesoc==1.12 && \
    pip3 install  vunit-hdl==4.6.0
    # pip3 install --upgrade pip && \
    # pip3 install --break-system-packages -e \
    #     git+https://github.com/olofk/edalize.git@1a5f926ae23eb33136c4dcf80236ac96b9870720#egg=edalize && \

# Install ssh
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt -y install tzdata \
    openssh-server rsync \
    iproute2 \
    && apt clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN mkdir -p /root/.ssh/ && chmod 700 /root/.ssh/ && \
    touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

RUN echo '\
export PATH=${PATH:-}:/opt/questasim/questasim/linux_x86_64\n\
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:/opt/questasim/questasim/linux_x86_64\n\
export LM_LICENSE_FILE=/opt/questasim/license.dat\n\
' > /root/.modelsim-env-vars

RUN echo 'source /root/.modelsim-env-vars' >> /root/.profile

COPY ./scripts/config-ssh-server.sh /tmp/
RUN /tmp/config-ssh-server.sh && rm /tmp/config-ssh-server.sh

RUN apt-get update && apt-get install -y iputils-ping tar sudo python-dev libssl-dev rng-tools
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && python2 get-pip.py
RUN python2 -m pip install --upgrade pip && \
    python2 -m pip install --upgrade setuptools && \
    python2 -m pip install --upgrade enum34 && \
    python2 -m pip install cryptography==2.2

RUN wget http://www.accellera.org/images/downloads/standards/uvm/uvm-1.2.tar.gz && \
    tar xfz uvm-1.2.tar.gz -C /usr/local/lib/ && \
    rm uvm-1.2.tar.gz
RUN sed -i 's|../uvm-1.1d|../uvm-1.2|g' /opt/questasim/questasim/modelsim.ini
RUN echo "source /root/.modelsim-env-vars\n$(cat /root/.bashrc)" > /root/.bashrc

CMD ["/usr/sbin/sshd", "-D"]

# TODO: /opt/questasim/questasim/gcc-5.3.0-linux_x86_64/bin/g++ -> /usr/bin/g++
# TODO: /opt/questasim/questasim/gcc-5.3.0-linux_x86_64/bin/gcc -> /usr/bin/gcc
