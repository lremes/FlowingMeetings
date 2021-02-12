#!/bin/bash

mkdir -p locale/update/en
export I18N_UPDATE_ONLY='true'
rake formtastic:store_formtastic_attributes
rake i18n:find_keys
rake gettext:find
rake i18n:remove_unused_keys
cp locale/update/lawly.pot locale/lawly.pot
rm -rf locale/update
unset I18N_UPDATE_ONLY
