# Pull base image.
FROM ubuntu:14.04

# Install packages.
RUN apt-get update && \
apt-get install -y git && \
apt-get build-dep -y ruby1.9.3 && \
apt-get install -y libxslt1-dev libcurl4-openssl-dev libksba8 libksba-dev libqtwebkit-dev libreadline-dev && \
apt-get install -y libsqlite3-dev sqlite3 postgresql postgresql-server-dev-all && \
apt-get install -y redis-server exuberant-ctags vim-gtk tmux imagemagick watch curl && \
apt-get install -y zsh nodejs silversearcher-ag wget

# Change shell to ZSH
RUN chsh -s $(which zsh)

# Install chruby and ruby-install
RUN wget -O /tmp/chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && \
cd /tmp/ && tar -xzvf chruby-0.3.9.tar.gz && cd /tmp/chruby-0.3.9/ && make install && \
cd && rm -rf /tmp/chruby-0.3.9/
RUN wget -O /tmp/ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz && \
cd /tmp/ && tar -xzvf ruby-install-0.5.0.tar.gz && cd /tmp/ruby-install-0.5.0 && make install && \
cd && rm -rf /tmp/ruby-install-0.5.0/

# Install rcm
RUN wget -O /tmp/rcm_1.2.3-1_all.deb https://thoughtbot.github.io/rcm/debs/rcm_1.2.3-1_all.deb && \
dpkg -i /tmp/rcm_1.2.3-1_all.deb && rm -f /tmp/rcm_1.2.3-1_all.deb
