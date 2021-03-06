require 'minitest/autorun'
require 'yaml'
require './lib/classes/users/ksu_user'
require './lib/classes/institution'

# test for specialized KSU patron functionality
class KsuUserTest < MiniTest::Test
  TEST_DATA_FILE = './config/test_data.yml'.freeze

  def setup
    test_data = YAML.load_file TEST_DATA_FILE
    test_inst = Institution.new 'ksu'
    @user = KsuUser.new test_data['ksu_test'], test_inst
  end

  def test_has_user_group
    assert_kind_of UserGroup, @user.user_group
  end

  def test_has_primary_id
    assert_equal '000123456', @user.primary_id
  end

  def test_has_secondary_id
    assert_equal 'secondry', @user.secondary_id
  end

  def test_has_expiry_date_from_file
    assert_equal '2017.08.31', @user.original_expiry_date
  end

  def test_has_sif_date_for_alma_expiry_date
    assert_equal '2017-08-31Z', @user.exp_date_for_alma
  end

  def test_has_barcode
    assert_equal '12345678900000', @user.barcode
  end

  def test_has_first_name
    assert_equal 'Robert', @user.first_name
  end

  def test_has_middle_name
    assert_equal 'F', @user.middle_name
  end

  def test_has_last_name
    assert_equal 'Gates', @user.last_name
  end

  def test_has_primary_address_line_1
    assert_equal '1234 Renaissance St NW', @user.primary_address_line_1
  end

  def test_has_primary_address_line_2
    assert_equal 'Room 12', @user.primary_address_line_2
  end

  def test_has_primary_address_city
    assert_equal 'Atlanta', @user.primary_address_city
  end

  def test_has_primary_address_postal_code
    assert_equal '30000', @user.primary_address_postal_code
  end

  def test_has_primary_address_state_province
    assert_equal 'GA', @user.primary_address_state_province
  end

  def test_has_primary_address_country
    assert_equal '', @user.primary_address_country
  end

  def test_has_primary_address_phone
    assert_equal '(123) 456-7890', @user.primary_address_phone
  end

  def test_has_primary_address_mobile_phone
    assert_equal '(111) 222-3333', @user.primary_address_mobile_phone
  end

  def test_has_email
    assert_equal 'settingw@kennesaw.edu', @user.email
  end
end
