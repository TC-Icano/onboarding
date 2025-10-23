FROM erlang:28-alpine

WORKDIR /app

# Install curl, build tools, and Redis
RUN apk add --no-cache curl bash git make gcc g++ redis

COPY . .

# Download rebar3
RUN curl -Lo rebar3 https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3

# Compile deps and build release
RUN ./rebar3 get-deps compile
RUN ./rebar3 release

EXPOSE 8080

# Create a startup script that runs Redis in background and then the Erlang app
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'redis-server --daemonize yes --bind 0.0.0.0' >> /start.sh && \
    echo 'sleep 2' >> /start.sh && \
    echo '_build/default/rel/staff_roles/bin/staff_roles foreground' >> /start.sh && \
    chmod +x /start.sh

# Run both Redis and the Erlang application
CMD ["/start.sh"]
