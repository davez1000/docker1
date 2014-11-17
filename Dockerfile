FROM ubuntu

MAINTAINER Dave Brown <stuff@davs.me>

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

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

RUN a2enmod rewrite.load

RUN mkdir /srv/application

RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
ADD resources/ssh/github_temp /root/.ssh/id_rsa
RUN chmod 0600 /root/.ssh/id_rsa
RUN touch /root/.ssh/config
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

RUN git clone git@github.com:davez1000/symfony2t.git /srv/application
RUN chown -R www-data:www-data /srv/application
#RUN rm -rf /srv/application/app/cache/*
RUN chmod 0777 /srv/application/app/cache

# add sites
RUN mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup
ADD resources/vhosts/default/default /etc/apache2/sites-available/000-default.conf

ADD resources/apps/run.sh /run.sh
RUN chmod 0755 /run.sh

EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND
#CMD ["/run.sh"]

