# # syntax = docker/dockerfile:1

# # Set Ruby version
# ARG RUBY_VERSION=3.3.6
# FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim-bookworm AS base

# # Prevent Ruby from downloading gems during build
# ENV RUBYGEMS_VERSION="" \
#     BUNDLE_VERSION="" \
#     GEM_HOME="/usr/local/bundle" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_WITHOUT="development:test" \
#     BUNDLE_JOBS="4" \
#     BUNDLE_RETRY="3" \
#     RAILS_ENV="production" \
#     NODE_ENV="production" \
#     RAILS_LOG_TO_STDOUT="true" \
#     RAILS_SERVE_STATIC_FILES="true" \
#     PORT="10000" 

# # Install production dependencies
# # libvips: image processing (fast alternative to ImageMagick)
# # ffmpeg: video previews
# # poppler-utils: PDF previews
# # libpq-dev, libssl-dev: DB + SSL support
# # ca-certificates: TLS/SSL trust
# # jemalloc: memory optimization
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y \
#         build-essential \
#         curl \
#         libpq-dev \
#         libvips-dev \
#         libssl-dev \
#         ca-certificates \
#         postgresql-client \
#         ffmpeg \
#         poppler-utils \
#         libjemalloc2 \
#     && rm -rf /var/lib/apt/lists/*

# # Use jemalloc for better memory management
# ENV MALLOC_ARENA_MAX=2
# ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# # Set working directory
# WORKDIR /rails

# # Copy Gemfile first to leverage layer caching
# COPY Gemfile Gemfile.lock ./

# # Install gems
# RUN gem install bundler && \
#     bundle config set without 'development test' && \
#     bundle install --jobs=4 && \
#     # Clean up gem cache and temp files
#     rm -rf ~/.bundle/ \
#            "${GEM_HOME}"/cache/*.gem \
#            "${GEM_HOME}"/gems/*/ext/*/.git \
#            "${GEM_HOME}"/gems/*/tmp \
#     && bundle exec bootsnap precompile --gemfile

# # Copy application code
# COPY . .

# # Precompile bootsnap for faster boot
# RUN bundle exec bootsnap precompile app/ lib/

# # Create non-root user
# RUN useradd --create-home --shell /bin/bash rails && \
#     mkdir -p /rails/tmp /rails/log /rails/storage /rails/db && \
#     chown -R rails:rails /rails

# # Switch to non-root user
# USER rails:rails

# # Add bin/ to PATH
# ENV PATH="/rails/bin:/usr/local/bundle/bin:$PATH"

# # Copy and set executable permissions for entrypoint
# COPY --chown=rails:rails ./bin/docker-entrypoint /rails/bin/docker-entrypoint
# RUN chmod +x /rails/bin/docker-entrypoint

# # Entrypoint
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Expose port (used for documentation; Render uses $PORT)
# EXPOSE $PORT

# # Healthcheck: uses $PORT, waits for app to respond
# HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
#   CMD curl -f http://localhost:$PORT/health || exit 1

# # Start Rails server, binding to $PORT
# # CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
# CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]



# syntax = docker/dockerfile:1

# Set Ruby version
ARG RUBY_VERSION=3.3.6
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim-bookworm AS base

# Environment defaults
ENV GEM_HOME="/usr/local/bundle" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3" \
    RAILS_LOG_TO_STDOUT="true" \
    RAILS_SERVE_STATIC_FILES="true" \
    PORT="3000"

# Set working directory
WORKDIR /rails

# Install OS packages & jemalloc
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        libpq-dev \
        libvips-dev \
        libssl-dev \
        ca-certificates \
        postgresql-client \
        ffmpeg \
        poppler-utils \
        libjemalloc2 \
    && rm -rf /var/lib/apt/lists/*

# Set jemalloc preload ONLY if present
RUN JEMALLOC_PATH=$(dpkg -L libjemalloc2 | grep -m1 jemalloc.so.2) && \
    if [ -f "$JEMALLOC_PATH" ]; then \
      echo "Using jemalloc: $JEMALLOC_PATH" && \
      echo "export LD_PRELOAD=$JEMALLOC_PATH" >> /etc/profile.d/jemalloc.sh; \
    else \
      echo "jemalloc not found, skipping preload"; \
    fi

# Copy Gemfile first for caching
COPY Gemfile Gemfile.lock ./

# Install Bundler & gems
RUN gem install bundler && \
    bundle config set without 'development test' && \
    bundle install --jobs=4 && \
    rm -rf ~/.bundle/ \
           "${GEM_HOME}"/cache/*.gem \
           "${GEM_HOME}"/gems/*/ext/*/.git \
           "${GEM_HOME}"/gems/*/tmp \
    && bundle exec bootsnap precompile --gemfile

# Copy app code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Create non-root user
RUN useradd --create-home --shell /bin/bash rails && \
    mkdir -p /rails/tmp /rails/log /rails/storage /rails/db && \
    chown -R rails:rails /rails

USER rails:rails

# Add bin/ to PATH
ENV PATH="/rails/bin:/usr/local/bundle/bin:$PATH"

# Copy entrypoint
COPY --chown=rails:rails ./bin/docker-entrypoint /rails/bin/docker-entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Expose port
# EXPOSE $PORT
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD curl -f http://localhost:$PORT/health || exit 1

# Default CMD: Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]


