#!/bin/bash
# render-build.sh

# Install dependencies
bundle install

# Precompile assets
bundle exec rails assets:precompile

# Run database migrations (optional, if preDeployCommand is not available)
# bundle exec rails db:migrate
bundle exec rails assets:clean

# If you're using a Free instance type, you need to
# perform database migrations in the build command.
# Uncomment the following line:

# bundle exec rails db:migrate