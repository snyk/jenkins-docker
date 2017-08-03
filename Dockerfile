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

# Don't run as root
WORKDIR /home/node
USER node


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
