require './lib/errors/no_group_mapping_error'

# functionality for patron user_group including support for weighting
class UserGroup
  attr_accessor :type, :alma_name, :banner_name, :weight, :institution, :exp_days

  def initialize(institution, campus, banner_name = nil, fs_codes = nil)
    self.institution = institution
    create_group_data banner_name, fs_codes, campus
    copy_config_values
  end

  def to_s
    alma_name
  end

  private

  def heavier_than?(user_group)
    user_group.weight < weight
  end

  def copy_config_values
    if @data && @data['alma_name'] && @data['weight']
      self.alma_name = @data['alma_name']
      self.weight = @data['weight'].to_i
      self.type = @data['type']
      self.exp_days = @data['exp_days']
    else
      fail NoGroupMappingError, 'Insufficient data to properly map group, using default.'
    end
  end

  def create_group_data(banner_name, fs_codes, campus)
    @data = nil
    if banner_name && banner_name != ''
      create_from_banner banner_name, campus
    elsif fs_codes
      fail(
        NotImplementedError,
        'FS Codes cannot be translated to User Groups if a Campus has been provided.'
      ) if campus
      create_from_fs_codes fs_codes
    end
  end

  def create_from_banner(banner_name, campus = nil)
    groups_settings = if campus
                        campus.groups_settings
                      else
                        institution.groups_settings
                      end
    self.banner_name = banner_name
    @data = groups_settings[banner_name]
  end

  def create_from_fs_codes(fs_codes)
    fs_codes.each do |fs_code|
      next unless institution.groups_data.key? fs_code
      alma_name = institution.groups_data[fs_code]
      group_settings = institution.groups_settings[alma_name]
      @data = group_settings if !@data || group_settings['weight'] > @data['weight']
    end
  end
end