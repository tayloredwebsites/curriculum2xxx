require 'helpers/test_components_helper'

class UserTest < ActiveSupport::TestCase

  test "no email or password fails" do
    user = User.new()
    refute user.valid?, 'missing email is missing error'
  end

  test "with no password fails" do
    user = User.new(email: 'testing@sample.com',
      given_name: "Joe",
      family_name: "Morning"
    )
    refute user.valid?, 'missing password is missing error'
  end

  test "with mismatched passwords fails" do
    user = User.new(email: 'testing@sample.com',
      given_name: "Joe",
      family_name: "Morning",
      password: 'password',
      password_confirmation: 'testing2'
    )
    refute user.valid?, 'mismatched emails is missing error'
  end

  test "with email and no extra fields fails" do
    user = User.create(email: 'testing@sample.com',
      given_name: "Morning",
      family_name: "Joe",
      password: 'password',
      password_confirmation: 'password'
    )
    refute user.valid?
  end

  test "with email, extra fields, and no terms fails" do
    user = User.create(email: 'testing@sample.com',
      given_name: "Morning",
      family_name: "Joe",
      password: 'password',
      password_confirmation: 'password',
      govt_level: "1",
      govt_level_name: "govt_level_name",
      municipality: "municipality",
      institute_type: "1",
      institute_name_loc: "institute_name_loc",
      position_type: "1",
      subject1: "subject1",
      subject2: "subject2",
      gender: "2",
      education_level: "1",
      work_phone: "work_phone",
      work_address: "work_address",
      terms_accepted: false
    )
    refute user.valid?
  end

  test "with email, extra fields, and terms succeeds" do
    user = User.create(email: 'testing@sample.com',
      given_name: "Morning",
      family_name: "Joe",
      password: 'password',
      password_confirmation: 'password',
      govt_level: "1",
      govt_level_name: "govt_level_name",
      municipality: "municipality",
      institute_type: "1",
      institute_name_loc: "institute_name_loc",
      position_type: "1",
      subject1: "subject1",
      subject2: "subject2",
      gender: "2",
      education_level: "1",
      work_phone: "work_phone",
      work_address: "work_address",
      terms_accepted: true
    )
    assert user.valid?
  end

end
