FROM debian:stable

MAINTAINER me@bstr.eu
RUN apt-get update
RUN apt-get install -y  nagios-nrpe-server
ADD startup.sh /opt/startup.sh
RUN sed -e 's/^server_address=127.0.0.1/#server_address=127.0.0.1/' \
        -e 's/^allowed_hosts=127.0.0.1/#allowed_hosts=127.0.0.1/' \
        -i /etc/nagios/nrpe.cfg

RUN echo "command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20" >> /etc/nagios/nrpe.d/load.cfg

EXPOSE 5666

CMD ["/opt/startup.sh"]
