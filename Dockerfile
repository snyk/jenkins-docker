FROM node:6

MAINTAINER Snyk Ltd

# Install snyk cli
RUN npm install --global snyk snyk-to-html
RUN apt-get update
RUN apt-get install jq

#Install maven and python
RUN apt-get install -y maven python-pip python-dev build-essential
RUN pip install --upgrade pip
RUN pip install --upgrade virtualenv

#Install gradle
RUN curl -L https://services.gradle.org/distributions/gradle-2.8-bin.zip -o gradle-2.8-bin.zip
RUN apt-get install -y unzip
RUN unzip gradle-2.8-bin.zip
ENV GRADLE_HOME=/gradle-2.8
ENV PATH=$PATH:$GRADLE_HOME/bin

#Install sbt
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-get install apt-transport-https
RUN echo "deb http://http.debian.net/debian jessie-backports main" |  tee --append /etc/apt/sources.list.d/jessie-backports.list > /dev/null
RUN apt-get update
#RUN apt-get install -y -t jessie-backports openjdk-8-jdk
#RUN update-java-alternatives -s java-1.8.0-openjdk-amd64
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
RUN curl -L -o sbt.deb http://dl.bintray.com/sbt/debian/sbt-0.13.16.deb
RUN dpkg -i sbt.deb
RUN apt-get update
# RUN echo "docker-user:x:503:503::/home/node:/bin/bash" >> /etc/passwd

RUN echo "docker-user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir -p /home/node/.sbt/0.13/plugins
RUN echo "addSbtPlugin(\"net.virtual-void\" % \"sbt-dependency-graph\" % \"0.8.2\")" >> /home/node/.sbt/0.13/plugins/build.sbt
RUN echo "net.virtualvoid.sbt.graph.DependencyGraphSettings.graphSettings" >> /home/node/.sbt/0.13/user.sbt

RUN chmod -R a+wrx /home/node
WORKDIR /home/node
# USER node
ENV HOME /home/node
ENV M2 /home/node/.m2

# Don't run as root
###################################
# Custom Snyk configuration       #
# Redefine in derived Dockerfile, #
# or provide as runtime args `-e` #
###################################

# Your API token, obtained from snyk.io/account
# ENV SNYK_TOKEN <snyk-api-token>

# The path at which the project is mounted (-v runtime arg)
ENV PROJECT_PATH /project

# Output will be redirected to $PROJECT_PATH/$OUTPUT_FILE
# Stdout is used if OUTPUT_FILE is omitted
# ENV OUTPUT_FILE snyk-result

ADD docker-entrypoint.sh .
ADD snyk_report.css .
ENTRYPOINT ["./docker-entrypoint.sh"]

# Default command is `snyk test`
# Override with `docker run ... snyk/snyk <command> <args>`
CMD ["test"]
