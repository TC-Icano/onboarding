FROM erlang:28-alpine

WORKDIR /app

# Install curl and build tools (removed Redis since it's now a separate service)
RUN apk add --no-cache curl bash git make gcc g++

# Copy source files
COPY . .

# Download rebar3 if not present
RUN if [ ! -f rebar3 ]; then \
        curl -Lo rebar3 https://s3.amazonaws.com/rebar3/rebar3 && \
        chmod +x rebar3; \
    fi

# Ensure rebar3 is executable
RUN chmod +x rebar3

# Clean any previous builds and compile
RUN ./rebar3 clean
RUN ./rebar3 deps get
RUN ./rebar3 compile
RUN ./rebar3 release

# Verify the release was created
RUN ls -la _build/default/rel/staff_roles/bin/

EXPOSE 8080

# Run the Erlang application
CMD ["_build/default/rel/staff_roles/bin/staff_roles", "foreground"]
