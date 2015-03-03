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

# Install latest version of Ruby and change to that version
RUN ruby-install ruby "$(curl -sSL http://ruby.thoughtbot.com/latest)" -- --disable-install-rdoc
RUN source /usr/local/share/chruby/chruby.sh
RUN chruby "$(curl -sSL http://ruby.thoughtbot.com/latest)"

# Update Rubygems and install gems
RUN gem update --system && \
gem install bundler --no-document --pre && \
bundle config --global jobs $(($(nproc)-1)) && \
gem install suspenders --no-document && \
gem install parity --no-document

# Install Heroku CLI client and configuration options
RUN curl -s https://toolbelt.heroku.com/install-ubuntu.sh | sh && \
heroku plugins:install git://github.com/ddollar/heroku-config.git

# Install GitHub CLI client
RUN curl https://github.com/jingweno/gh/releases/latest -s | cut -d'v' -f2 | cut -d'"' -f1 > /tmp/gh_version
RUN curl "https://github.com/jingweno/gh/releases/download/v$(cat /tmp/gh_version)/gh_$(cat /tmp/gh_version)_amd64.deb" -sLo gh.deb
RUN dpkg -i gh.deb

# Install rcm
RUN wget -O /tmp/rcm_1.2.3-1_all.deb https://thoughtbot.github.io/rcm/debs/rcm_1.2.3-1_all.deb && \
dpkg -i /tmp/rcm_1.2.3-1_all.deb && rm -f /tmp/rcm_1.2.3-1_all.deb

# Retrieve and install dotfiles
WORKDIR /root
RUN git clone git://github.com/thoughtbot/dotfiles.git
RUN env RCRC=$HOME/dotfiles/rcrc rcup
RUN cd && git clone git@github.com:kenyonj/dotfiles-local.git
RUN cd && cd dotfiles-local && bin.local/setup
