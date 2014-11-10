FROM ubuntu

MAINTAINER Dave Brown <stuff@davs.me>

RUN apt-get update

# disable interactive warnings
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# preset mysql login details
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password seen true" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again seen true" | debconf-set-selections

RUN apt-get install -y \
	curl \
	apache2 \
	mysql-server \
	php5 php5-mysql \
	libapache2-mod-auth-mysql \
	libapache2-mod-php5 \
	php5-xsl \
	php5-gd \
	php-pear \
	git
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD resources/dotfiles/vimrc /root/.vimrc

# add sites
ADD resources/vhosts/sucesionaranda/sucesionaranda.dev.conf /etc/apache2/sites-available/sucesionaranda.dev.conf
RUN a2ensite sucesionaranda.dev.conf
RUN mkdir -p /var/www/sucesionaranda.dev
ADD resources/vhosts/sucesionaranda/index.html /var/www/sucesionaranda.dev/index.html

ADD resources/apps/run.sh /run.sh
RUN chmod 0755 /run.sh

EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND
#CMD ["/run.sh"]

