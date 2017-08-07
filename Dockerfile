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

# Don't run as root
RUN chmod -R a+wrx /home/node
WORKDIR /home/node
USER node
ENV HOME /home/node
ENV M2 /home/node/.m2
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
