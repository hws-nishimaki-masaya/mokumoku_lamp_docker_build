FROM centos:latest
MAINTAINER "Masaya Nishimaki" <nishimaki.masaya@headwaters.co.jp>

# Run updates
RUN yum -y install epel-release;
RUN yum -y update && yum -y clean all;

# Install Apache HTTP
RUN yum -y install httpd
RUN httpd -v

# Install MySQL
## Install Mroonga Package
RUN yum -y install http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
## Install MySQL Community Server
RUN yum -y install http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
RUN yum -y install mysql-community-server
RUN mysqld --version
RUN rpm -qa | grep -i mysql
## Install Mroonga Plungin, tokenizer MeCab
RUN yum -y install mysql-community-mroonga
RUN yum -y install groonga-tokenizer-mecab

# Install PHP
RUN yum install -y php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml

# install supervisord
RUN yum install -y python-pip && pip install "pip>=1.4,<1.5" --upgrade; yum clean all;
RUN pip install supervisor

# install sshd
RUN yum install -y openssh-server openssh-clients passwd; yum clean all;

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && echo 'root:changeme' | chpasswd

ADD phpinfo.php /var/www/html/
ADD supervisord.conf /etc/
EXPOSE 22 80 443 3306
CMD ["supervisord", "-n"]
