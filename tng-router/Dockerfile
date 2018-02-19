FROM ruby:2.4.3-slim-stretch
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential libcurl3 libcurl3-gnutls libcurl4-openssl-dev && \
	  rm -rf /var/lib/apt/lists/*
RUN mkdir -p /app/lib/local-gems
WORKDIR /app
COPY Gemfile /app
RUN bundle install
COPY . /app
EXPOSE 5000
ENV PORT 5000
ENV ROUTES_FILE=sp_routes.yml
CMD ["bundle", "exec", "rackup", "-p", "5000", "--host", "0.0.0.0"]
