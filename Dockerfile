# syntax = docker/dockerfile:1

# Set Ruby version
ARG RUBY_VERSION=3.3.6
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set working directory
WORKDIR /rails

# Set environment variables for production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Build stage to install dependencies and precompile assets
FROM base as build

# Install build dependencies for gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the application code
COPY . .

# Copy docker-entrypoint script
COPY ./bin/docker-entrypoint /rails/bin/docker-entrypoint

# Precompile bootsnap code for faster boot time
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for the production image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built gems and application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Ensure correct file ownership and permissions
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p /rails/db /rails/log /rails/storage /rails/tmp && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp /rails/bin

USER rails:rails

# Make sure the entrypoint script is executable
RUN chmod +x /rails/bin/docker-entrypoint

# Set entrypoint to run the entrypoint script
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose the Rails default port
EXPOSE 3000

# Default command to start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
