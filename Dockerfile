FROM ruby:2.4

RUN apt-get update && apt-get install -q -y xvfb libxi6 libgconf-2-4 wget dpkg unzip

# Set up the Chrome PPA
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Update the package list and install chrome
RUN apt-get update -y
RUN apt-get install -y google-chrome-stable

# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION 2.33
ENV CHROMEDRIVER_DIR /chromedriver
RUN mkdir $CHROMEDRIVER_DIR

# Download and install Chromedriver
RUN wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
RUN unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR

# Put Chromedriver into the PATH
ENV PATH $CHROMEDRIVER_DIR:$PATH
ENV LOG_FILE=/var/log/browser-xvfb.log
ENV DISPLAY=:10

RUN Xvfb :10 -screen 0 1366x768x24 -ac +extension RANDR & > ${LOG_FILE}

ENV APP_HOME /app
RUN mkdir -p ${APP_HOME}

COPY ./app ${APP_HOME}
RUN cd ${APP_HOME} && bundle install

CMD /bin/bash
