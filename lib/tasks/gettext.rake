# Remove the provided gettext setup task
Rake::Task["gettext:setup"].clear

namespace :gettext do
    def files_to_translate
        Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,axslx}")
    end

    task :setup => [:environment] do
        locale_path = 'locale/'

        FastGettext.default_text_domain = 'app'
    	FastGettext.default_available_locales = [ :en ] #Rails.application.config.i18n.available_locales
	    FastGettext.default_locale = :en

        domain = FastGettext.text_domain
        files = files_to_translate

        GetText::Tools::Task.define do |task|
            task.package_name = domain
            task.package_version = "1.0.0"
            task.domain = domain
            task.po_base_directory = locale_path
            task.mo_base_directory = locale_path
            task.files = files
            task.enable_description = false
            task.msgmerge_options = gettext_msgmerge_options
            task.msgcat_options = gettext_msgcat_options
            task.xgettext_options = gettext_xgettext_options
        end
    end
end
