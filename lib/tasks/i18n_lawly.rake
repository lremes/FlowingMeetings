namespace :i18n do
  desc "Find translation keys"
  task :find_keys => :environment do
    keys = TranslationKeysFinder.new()
    #finder.find_missing_keys
    paths = keys.title_parts.uniq
    File.open("locale/page_titles.rb", 'w') {
      |file|
      file.write("# DO NOT EDIT! CREATED BY rake i18n:find_keys\n") 
      titles = paths.map { |p| p[0] }.uniq
      titles.each { |t|
        file.write("N_('PageTitle|#{t}')\n") unless /api\/v1/.match(t)
      }
    }
  end

  task :remove_unused_keys => :environment do
    require 'find'
    require 'poparser'

    filename = "./locale/blacklisted_keys.txt"
    blacklisted = []
    if File.file?(filename)
      blacklisted = File.open(filename, 'r').readlines().map { |l| l.strip }
      blacklisted.reject! { |l| l.starts_with?('#') } # remove comment lines
    end

    puts blacklisted.inspect

    # look up files to translate
    pot_files = []
    po_files = []
    Find.find('./locales/') do |path|
      pot_files << path if path =~ /.*\.pot$/
      #po_files << path if path =~ /.*\.po$/
    end

    # Process POT files
    pot_files.each do |pot_filename|
      puts "Processing #{pot_filename}"
      pot = PoParser.parse_file(pot_filename)

      pot.entries.each do |e|
        if e.msgid.to_s.starts_with?('#{')
          puts "Deleting hash key #{e.msgid.to_s}"
          pot.delete(e)
          next
        end
        
        blacklisted.each do |key|
          if e.msgid.to_s =~ /#{key}/
            #puts "#{key} =~ #{e.msgid.to_s}"
            puts "Deleting blacklisted key #{e.msgid.to_s}"
            pot.delete(e)
          end
        end
      end
      pot.save_file
    end

    # process PO files
    po_files.each do |po_filename|
      puts "Processing #{po_filename}"
      po = PoParser.parse_file(po_filename)

      po.entries.each do |e|
        if e.msgid.to_s.starts_with?('#{')
          puts "Deleting hash key #{e.msgid.to_s}"
          po.delete(e)
          next
        end
        blacklisted.each do |key|
          if e.msgid.to_s =~ /#{key}/
            puts "Deleting blacklisted key #{e.msgid.to_s}"
            po.delete(e)
          end
        end
      end
      po.save_file
    end
  end
end

class TranslationKeysFinder
  attr_reader :paths

  def initialize()
    @routes = Rails.application.routes.routes
  end

  def title_parts
    @title_parts ||= begin
      @routes.collect { |r| check_route(r) }.compact.uniq.sort
    end
  end

  def check_route(route)
    wrapper = ActionDispatch::Routing::RouteWrapper.new(route)
    controller_class_name = "#{wrapper.controller}_controller".camelize
    #puts "#{controller_class_name}##{wrapper.action}"
    begin
      klass = Class.new controller_class_name.constantize
      if klass.method_defined?(wrapper.action)
        #return "#{wrapper.controller}##{wrapper.action}"
        return [ wrapper.controller, wrapper.action ]
      else
        puts "\tNo method implementation found for #{wrapper.controller}##{wrapper.action}"
      end
    rescue => ex
      puts ex
      puts "No CONTROLLER found for #{route.path.spec.to_s} #{controller_class_name}"
    end
  end

end