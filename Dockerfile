FROM node:6

MAINTAINER Snyk Ltd

# Install snyk cli
RUN npm install --global snyk snyk-to-html && \
    apt-get update && \
    apt-get install jq

#Install maven and python
RUN apt-get install -y maven python-pip python-dev build-essential && \
  pip install --upgrade pip  && \
  pip install --upgrade virtualenv

#Install gradle
RUN curl -L https://services.gradle.org/distributions/gradle-2.8-bin.zip -o gradle-2.8-bin.zip && \
  apt-get install -y unzip && \
  unzip gradle-2.8-bin.zip -d /home/node/

ENV GRADLE_HOME=/home/node/gradle-2.8
ENV PATH=$PATH:$GRADLE_HOME/bin

#Install sbt
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-get install apt-transport-https && \
    echo "deb http://http.debian.net/debian jessie-backports main" |  tee --append /etc/apt/sources.list.d/jessie-backports.list > /dev/null && \
    apt-get update  && \
    curl -L -o sbt.deb http://dl.bintray.com/sbt/debian/sbt-0.13.16.deb  && \
    dpkg -i sbt.deb  && \
    apt-get update

RUN echo "docker-user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers  && \
    mkdir -p /home/node/.sbt/0.13/plugins  && \
    echo "addSbtPlugin(\"net.virtual-void\" % \"sbt-dependency-graph\" % \"0.8.2\")" >> /home/node/.sbt/0.13/plugins/build.sbt && \
    echo "net.virtualvoid.sbt.graph.DependencyGraphSettings.graphSettings" >> /home/node/.sbt/0.13/user.sbt

RUN apt-get install -y -t jessie-backports openjdk-8-jdk && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64

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
