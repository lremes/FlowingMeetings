#!/bin/bash

if [ $# -ne 1 ]
then
echo "Usage: $0 version_to_push"
exit 1
fi

export APP_VERSION="${1}"
export RAILS_ENV="production" # this is needed for bundler

echo "Building ${APP_VERSION} (${RAILS_ENV}) for Azure"

RUBY_VERSION="2.7.2"

cd .. && bin/prerelease.sh

# run brakeman
#brakeman

# run licence_finder
#bundle exec license_finder

LOCALE_FILES=`find locale -type f -name '*.po'`

tar -czvf packer/app.tar.gz app/ bin/ db/ lib/ public/ \
locale/app.pot ${LOCALE_FILES} \
config.ru Gemfile Gemfile.lock Rakefile \
config/boot.rb config/initializers config/puma.rb config/routes.rb \
config/spring.rb config/storage.yml config/application.rb config/environment.rb config/webpacker.yml \
config/credentials.yml.enc config/environments/production.rb config/database.yml config/cable.yml config/master.key
cd packer
packer build rails-ruby-alpine-${RUBY_VERSION}-x86_64.json
