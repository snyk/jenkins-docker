FROM node:8.9.1-slim

MAINTAINER Snyk Ltd

# Install snyk cli
RUN npm install --global snyk snyk-to-html && \
    apt-get update && \
    apt-get install -y jq

# Install Java 8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list

# Accept license non-iteractive
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN apt-get install -y oracle-java8-installer oracle-java8-set-default

#Install sbt
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-get install apt-transport-https && \
    curl -L -o sbt.deb http://dl.bintray.com/sbt/debian/sbt-0.13.16.deb && \
    dpkg -i sbt.deb

RUN echo "docker-user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers  && \
    mkdir -p /home/node/.sbt/0.13/plugins  && \
    echo "addSbtPlugin(\"net.virtual-void\" % \"sbt-dependency-graph\" % \"0.8.2\")" >> /home/node/.sbt/0.13/plugins/build.sbt && \
    echo "net.virtualvoid.sbt.graph.DependencyGraphSettings.graphSettings" >> /home/node/.sbt/0.13/user.sbt && \
    echo "-sbt-version  0.13.16" >> /etc/sbt/sbtopts

RUN chmod -R a+wrx /home/node
WORKDIR /home/node
ENV HOME /home/node
ENV M2 /home/node/.m2

# The path at which the project is mounted (-v runtime arg)
ENV PROJECT_PATH /project

ADD docker-entrypoint.sh .
ADD run-snyk.sh .
ADD snyk_report.css .

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["test"]
