require './lib/classes/users/sif_user'

# specialty parsing for KSU file
class KsuUser < SifUser
  KSU_USER_SEGMENT_LENGTH = 466
  KSU_ADDRESS_SEGMENT_LENGTH = 429
  KSU_MAXIMUM_ADDRESS_SEGMENTS = 2
  VSU_EXPIRY_DATE_FORMAT = '%Y.%m.%d'.freeze
  KSU_GENERAL_MAPPING = {
    barcode:                [20, 35],
    original_user_group:    [45, 55],
    secondary_id:           [76, 84],
    original_expiry_date:   [198, 209],
    primary_id:             [238, 248],
    last_name:              [310, 330],
    first_name:             [340, 360],
    middle_name:            [360, 380]
  }.freeze
  KSU_ADDRESS_SEGMENT_MAPPING = {
    address_type:             [0, 1],
    address_line_1:           [22, 72],
    address_line_2:           [72, 112],
    address_city:             [232, 272],
    address_state_province:   [272, 279],
    address_postal_code:      [279, 289],
    address_country:          [289, 309],
    address_phone:            [309, 335],
    address_mobile_phone:     [384, 409]
  }.freeze

  def general_mapping
    KSU_GENERAL_MAPPING
  end

  def user_segment_length
    KSU_USER_SEGMENT_LENGTH
  end

  def address_segment_length
    KSU_ADDRESS_SEGMENT_LENGTH
  end

  def maximum_address_segments
    KSU_MAXIMUM_ADDRESS_SEGMENTS
  end

  def address_segment_mapping
    KSU_ADDRESS_SEGMENT_MAPPING
  end

  # use expiration date provided in SIF when returning expiry date for Alma
  def exp_date_for_alma
    alma_date(DateTime.strptime(original_expiry_date, VSU_EXPIRY_DATE_FORMAT).strftime('%Y-%m-%d'))
  end
end