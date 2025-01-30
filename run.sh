#!/bin/bash

# script for running my ruby file [im just lazy 🌙✨]

# Install bundler if not exists
if ! gem list bundler -i > /dev/null; then
  echo "Bundler was not found installing"
  gem install bundler
fi

# run script
bundle install
bundle exec ruby lumen.rb