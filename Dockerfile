FROM ubuntu:16.04

# Install Nginx.
RUN \
  apt-get update && \
  apt-get install -y gcc g++ nginx curl && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Set default site
RUN rm /etc/nginx/sites-available/default
COPY default /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Install rust-lang
ENV CARGO_HOME /cargo
ENV PATH $CARGO_HOME/bin:/root/.cargo/bin:$PATH
RUN curl https://sh.rustup.rs -sSf \
  | env -u CARGO_HOME sh -s -- -y \
  && rustc --version && cargo --version \
  && mkdir -p "$CARGO_HOME"

# Build app
COPY ./app /app
WORKDIR /app
RUN rm -rf ./target
RUN cargo build --release

# Setup supervisor
RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443
CMD ["/usr/bin/supervisord"]
