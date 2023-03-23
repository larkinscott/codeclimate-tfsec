# Use an official Ruby runtime as a parent image
FROM ruby:2.7-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the Ruby script into the container
COPY lib/cc/plugin/codeclimate_tfsec.rb /usr/src/app/

# Install tfsec from GitHub
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 -O /usr/local/bin/tfsec && \
    chmod +x /usr/local/bin/tfsec && \
    apt-get remove -y wget unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --uid 9000 --disabled-password --quiet --gecos "app" app

COPY . /usr/src/app

RUN chown -R app:app /usr/src/app
USER app

WORKDIR /code

VOLUME /code

# Run the Ruby script when the container launches
CMD ["ruby", "/usr/src/app/codeclimate_tfsec.rb"]