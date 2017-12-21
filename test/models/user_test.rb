require 'test_helper'

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

  test "with email succeeds" do
    user = User.create(email: 'testing@sample.com',
      given_name: "Morning",
      family_name: "Joe",
      password: 'password',
      password_confirmation: 'password'
    )
    assert user.valid?
  end

end
