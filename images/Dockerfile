FROM cribl/scope:dev-x86_64
ENV LC_CTYPE C.UTF-8

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install openssh-server -y

# Uncomment for debug
# RUN apt update && DEBIAN_FRONTEND=noninteractive apt install openssh-server gdb git curl wget python3 python3-pip -y
# RUN python3 -m pip install pwn
# RUN python3 -m pip install keystone-engine ropper
# RUN git clone https://github.com/hugsy/gef.git
# RUN echo source `pwd`/gef/gef.py >> ~/.gdbinit
# RUN git clone https://github.com/openssh/openssh-portable
# RUN cd openssh-portable && git checkout V_8_2_P1 && autoreconf && ./configure --disable-strip && make -j "$(nproc)" && make install

RUN mkdir -p /etc/scope
COPY scope.yml /etc/scope

# Create a user group "foouser", "baruser"
RUN groupadd foouser
RUN groupadd baruser

# Create a user "foouser"
RUN useradd -ms /bin/bash -g foouser foouser
RUN echo foouser:foouser | chpasswd 
RUN mkdir -p /home/foouser/.ssh
RUN chmod 700 /home/foouser/.ssh
RUN chown -R foouser:foouser /home/foouser/.ssh
COPY --chown=foouser:foouser foouser_key.pub /home/foouser/.ssh/authorized_keys

# Create a user "baruser"
RUN useradd -ms /bin/bash -g baruser baruser
RUN echo baruser:baruser | chpasswd
RUN mkdir -p /home/baruser/.ssh
RUN chmod 700 /home/baruser/.ssh
RUN chown -R baruser:baruser /home/baruser/.ssh
COPY --chown=baruser:baruser baruser_key.pub /home/baruser/.ssh/authorized_keys

RUN mkdir -p /opt/secret_dir
RUN touch /opt/secret_dir/lorem.yml
RUN echo "secret_password: Lorem ipsum" > /opt/secret_dir/lorem.yml
RUN chmod 666 /opt/secret_dir/lorem.yml

# Start SSH service
RUN service ssh start
