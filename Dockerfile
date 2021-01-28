FROM nginx:alpine

USER root

ENV JAVA_HOME=/usr/java/jdk-11.0.6
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apk add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN apk update
RUN apk add util-linux pciutils usbutils coreutils binutils findutils grep
RUN apk add vim
RUN apk add git
RUN apk add bash bash-doc bash-completion
RUN apk update

RUN mkdir -p /root/app && chmod 775 /root/app

RUN cd /root/app

ADD ./scanner-jar.sh /root/app
ADD ./jar-run.sh /root/app
ADD ./jar-stop.sh /root/app
ADD ./docker-entrypoint.sh /root/app

WORKDIR /root/app

RUN sed -i -e 's/\r$//' /root/app/scanner-jar.sh
RUN sed -i -e 's/\r$//' /root/app/jar-run.sh
RUN sed -i -e 's/\r$//' /root/app/jar-stop.sh
RUN sed -i -e 's/\r$//' /root/app/docker-entrypoint.sh

RUN chmod 775 /root/app/scanner-jar.sh
RUN chmod 775 /root/app/jar-run.sh
RUN chmod 775 /root/app/jar-stop.sh
RUN chmod 775 /root/app/docker-entrypoint.sh

ENTRYPOINT ["/root/app/docker-entrypoint.sh"]
