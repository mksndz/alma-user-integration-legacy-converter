require_relative 'user'

# Parser object for standard ZORVLIB Process

class SifUser < User

  USER_SEGMENT_LENGTH       = 120
  ADDRESS_SEGMENT_LENGTH    = 328
  MAXIMUM_ADDRESS_SEGMENTS  = 9

  ADDRESS_TYPE_MAPPING = {
      '1': 'Permanent Address',
      '2': 'Temporary Address',
      '3': 'Email Address'
  }

  GENERAL_MAPPING = {
      user_group:          [0, 9],
      # registration_date:   [10, 19],
      primary_id:          [31, 41],
      last_name:           [43, 72],
      first_name:          [73, 92],
      middle_name:         [93, 112],
  }

  ADDRESS_SEGMENT_MAPPING = {
      address_type:             [0, 1],
      address_line_1:           [21, 70],
      address_line_2:           [71, 110],
      address_city:             [151, 190],
      address_state_province:   [191, 197],
      address_postal_code:      [198, 207],
      address_country:          [208, 227],
      address_phone:                    [228, 252],
      mobile_phone:             [253, 277],
  }

  def initialize(line_data, institution)
    @institution = institution
    @line_data = line_data

    user_data = extract_user_data
    address_data = extract_addresses

    user_data.each do |attr, value|
        set_value attr, value
    end

    address_data.each do |segment, data_hash|

      case segment
        when '1'
          # permanent
          set_primary_address(data_hash)
        when '2'
          # temporary
          set_secondary_address(data_hash)
        when '3'
          # email
          set_email_address(data_hash)
        else
          # discard?
      end

    end

  end

  def extract_addresses
    address_data = {}
    (1...MAXIMUM_ADDRESS_SEGMENTS).each do |segment_num|
      address_hash = extract_address_for_segment segment_num
      address_data[address_hash[:address_type]] = address_hash if address_hash
    end
    address_data
  end

  def extract_address_for_segment(segment_num)
    segment_start = USER_SEGMENT_LENGTH + ( (segment_num - 1) * ADDRESS_SEGMENT_LENGTH )
    segment_finish = segment_start + ADDRESS_SEGMENT_LENGTH
    address_segment = @line_data[segment_start...segment_finish]
    return nil unless address_segment && address_segment.strip != '' # exit if no address data
    address_data = {}
    ADDRESS_SEGMENT_MAPPING.each do |attr, width|
      address_data[attr] = @line_data[(segment_start + width[0])...(segment_start + width[1])].strip
    end
    address_data
  end

  def extract_user_data
    general_data = {}
    GENERAL_MAPPING.each do |attr, width|
      general_data[attr] = @line_data[width[0]..width[1]].strip
    end
    general_data
  end

  def set_primary_address(data_hash)
    data_hash.delete(:address_type)
    data_hash.each do |attr, value|
      set_value "primary_#{attr}", value
    end
  end

  def set_secondary_address(data_hash)
    data_hash.delete(:address_type)
    data_hash.each do |attr, value|
      set_value "secondary_#{attr}", value
    end
  end

  def set_email_address(data_hash)
    set_value 'email', data_hash[:address_line_1]
  end

  def set_value(attribute, value)
    self.send("#{attribute}=", value)
  end

end