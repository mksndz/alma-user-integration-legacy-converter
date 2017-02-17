require 'yaml'
require 'logger'
require './lib/classes/mailer'
require './lib/classes/user_group'

class Institution

  INSTITUTION_CONFIG_FILE       = './config/inst.yml'
  INSTITUTION_DATA_PATH         = '/gilftpfiles/'

  def initialize(code)

    @code = code
    inst_configs = YAML.load_file(INSTITUTION_CONFIG_FILE)
    @config = inst_configs[@code]
    unless @config
      raise StandardError.new("Institution config could not be loaded for #{@code}")
    end

    if @config['parent']
      set_parent_inst
      log_path = "#{INSTITUTION_DATA_PATH}#{parent_inst.code}/#{code}_log.log"
    else
      log_path = "#{INSTITUTION_DATA_PATH}#{code}/#{code}_log.log"
    end

    @institution_logger = Logger.new log_path
    @mailer = Mailer.new self

  end

  def logger
    @institution_logger
  end

  def mailer
    @mailer
  end

  def code
    @code
  end

  def parent_inst
    @parent_inst
  end

  def default_user_group
    UserGroup.new self, 'DEFAULT'
  end

  def barcode_separator
    @config['barcode_separator']
  end

  def alma_archive_path
    File.join INSTITUTION_DATA_PATH, code, 'archive'
  end

  def raw_archive_path
    File.join alma_archive_path, 'raw'
  end

  def notification_emails
    @config['notification_emails'] ? @config['notification_emails'] : []
  end

  def groups_data
    @config['user_group_conversion'] ? @config['user_group_conversion'] : {}
  end

  def groups_settings
    @config['user_group_settings'] ? @config['user_group_settings'] : {}
  end

  def expect_sif?
    @config['file_type'] == 'sif'
  end

  def expect_txt?
    @config['file_type'] == 'txt'
  end

  def user_class
    @config['user_class_file']
  end

  def path
    @config['path']
  end

  def process_facstaff?
    !@config['fac_staff'] == 'manual'
  end

  def expect_mixed?
    @config['fac_staff'] == 'mixed'
  end

  def expect_barcodes?
    !!@config['barcodes']
  end

  def expect_exp_date?
    !!@config['exp_date']
  end

  def autoexpire_missing_users?
    !!@config['expire_users']
  end

  private

  def set_parent_inst
    begin
      @parent_inst = Institution.new(@config['parent'])
    rescue StandardError => e
      @institution_logger.error "Parent Institution for #{code} could not be instantiated: #{e}"
    end
  end

end