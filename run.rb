require 'logger'
require 'yaml'
require 'zip'
require './lib/classes/institution'
require './lib/classes/file_handler'
require './lib/classes/zipper'
require './lib/classes/xml_factory'
require './lib/classes/mailer'
require './lib/util'
include Util::App

FILES_ROOT   = '/gilftpfiles'.freeze
LOG_FILE     = FILES_ROOT + '/logs/log.log'.freeze
DROP_POINT   = '/sis/synchronize'.freeze

start = Time.now

@script_logger = Logger.new LOG_FILE

# Load params
code = ARGV[0]

# TODO: check if file already exists for today, stop and warn

# Set Institution
begin
  institution = Institution.new(code)
rescue StandardError => e
  exit_log_error "Institution error: #{e.message}"
end

# Compose Run Set, containing files and run parameters
begin
  run_set = FileHandler.new(institution, ARGV).run_set
rescue StandardError => e
  exit_log_error "RunSet composition failed for #{code} with: #{e.message}", institution
end

# If the FileHandler found sufficient files to complete a run, based on the Institution's configuration, then proceed
if run_set.sufficient?

  # Run XmlFactory, which generates Users and applies the Templater to get an XML file
  begin
    output_file = XmlFactory.get_result run_set
  rescue StandardError => e
    exit_log_error "XmlFactory error for #{code} with: #{e.message}", institution
  end

  # zip up file
  begin
    zip_file = Zipper.do output_file, institution
  rescue StandardError => e
    exit_log_error "Zipper failed: #{e}"
  end

  unless run_set.dry_run?

    # MOVE FOR ALMA PICKUP
    source_file = File.join zip_file.path
    destination_file = File.join FILES_ROOT, institution.code, DROP_POINT, File.basename(zip_file.path)
    FileUtils.mv(source_file, destination_file)
    # institution.mailer.send_finished_notification
    institution.slacker.run_completed

  end

  duration = Time.now - start
  institution.logger.info "File Generation complete for #{institution.code} in #{duration} seconds."
  puts "File Generation complete for #{institution.code}"
  puts "Time: #{duration} seconds"

else

  puts "No files for #{institution.code}"

end

