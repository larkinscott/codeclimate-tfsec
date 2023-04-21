FROM ruby:2.7-slim

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

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

CMD ["/usr/src/app/bin/codeclimate-tfsec"]
