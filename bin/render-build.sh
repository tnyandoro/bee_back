#!/bin/bash
# render-build.sh
# Install dependencies
bundle install
# Run database migrations (optional, if preDeployCommand is not available)
bundle exec rails db:migrate