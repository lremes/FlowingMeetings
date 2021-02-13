#!/bin/bash

rake formtastic:store_formtastic_attributes
rake i18n:find_keys
rake gettext:find
