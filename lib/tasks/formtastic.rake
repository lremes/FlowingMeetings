namespace :formtastic do
 # This is more of an example, ignoring
  # the columns/tables that mostly do not need translation.
  # This can also be done with GetText::ActiveRecord
  # but this crashed too often for me, and
  # IMO which column should/should-not be translated does not
  # belong into the model
  #
  # You can get your translations from GetText::ActiveRecord
  # by adding this to you gettext:find task
  #
  # require 'active_record'
  # gem "gettext_activerecord", '>=0.1.0' #download and install from github
  # require 'gettext_activerecord/parser'
  desc "write the model attributes to <locale_path>/model_attributes.rb"
  task :store_formtastic_attributes => :environment do

    require 'formtastic/tasks'
    locale_path = "locale"
    storage_file = "#{locale_path}/formtastic_attributes.rb"
    puts "writing model translations to: #{storage_file}"

    ignore_tables = [/^sitemap_/, /_versions$/, 'schema_migrations', 'sessions', 'delayed_jobs']
    ignore_models = [ /HABTM_.*/ ]

    FormtasticTasks.store_model_attributes(
      :to => storage_file,
      :ignore_columns => [ /.*HABTM_.*/, 'id', 'created_at', 'updated_at' ],
      :ignore_tables => ignore_tables,
      :ignore_models => ignore_models
    )
  end
end