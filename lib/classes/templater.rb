require 'logger'
require 'erb'
require 'yaml'
require 'ostruct'
require './lib/util'
include Util::App
include Util::File

class Templater

  XML_TEMPLATE_FILE = './lib/templates/user_xml_v2_template.xml.erb'.freeze
  DEFAULTS_FILE = './config/defaults.yml'.freeze

  def self.run(users, run_set)

    institution = run_set.inst

    fail(StandardError, "Could not find XML template file @ #{XML_TEMPLATE_FILE}. Stopping.") unless File.exist? XML_TEMPLATE_FILE
    fail(StandardError, "Defaults file could not be found @ #{DEFAULTS_FILE}. Stopping.") unless File.exist? DEFAULTS_FILE

    defaults = YAML.load_file DEFAULTS_FILE

    fail(StandardError, 'Defaults config file not properly parsed. Stopping.') unless defaults.is_a? Hash

    template = File.open XML_TEMPLATE_FILE
    defaults = OpenStruct.new defaults['global']

    # Read template
    template = ERB.new(template.read)

    output_filename = "#{institution.code}_patrons_#{Time.now.strftime('%Y%m%d')}.xml"
    output_filepath = File.join(institution.alma_archive_path, output_filename)

    file = File.open(output_filepath, 'w')

    # Initialize XML
    file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<users>"

    # Write User XML to output file
    row = 1
    users.each do |user|
      begin
        user.order_phone_numbers
        xml = template.result(binding).gsub(/\n\s*\n/, "\n")
        file.puts xml
      rescue StandardError => te
        msg = "Error creating XML for User on row #{row}: #{te.message}"
        institution.logger.error msg
        institution.mailer.add_script_error_message msg
      ensure
        row += 1
      end
    end

    file.puts '</users>'
    file.close
    file

  end

end