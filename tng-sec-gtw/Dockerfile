FROM nginx
MAINTAINER Felipe Vicens <ATOS>
COPY default.conf /default.conf
COPY default-ssl.conf /default-ssl-template.conf
COPY default-no-ssl.conf /default-no-ssl-template.conf
COPY docker-entrypoint.sh /
ENV DOMAIN ""
EXPOSE 80 443
CMD ["/docker-entrypoint.sh"]
