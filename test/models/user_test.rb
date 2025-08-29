require "test_helper"

class UserTest < ActiveSupport::TestCase
  def with_stubbed_password_service(response)
    singleton = class << PasswordStrengthClient; self; end
    if PasswordStrengthClient.respond_to?(:check)
      singleton.send(:alias_method, :__orig_check, :check)
    end
    PasswordStrengthClient.define_singleton_method(:check) do |*args, **kwargs|
      response
    end
    yield
  ensure
    if singleton.method_defined?(:__orig_check)
      singleton.send(:alias_method, :check, :__orig_check)
      singleton.send(:remove_method, :__orig_check)
    else
      singleton.send(:remove_method, :check) rescue nil
    end
  end

  test "valid when password is strong per service" do
    strong_resp = PasswordStrengthClient::Response.new(ok: true, label: "STRONG", score: 0.98)

    with_stubbed_password_service(strong_resp) do
      user = User.new(email: "strong@example.com", password: "Abc!2345", password_confirmation: "Abc!2345")
      assert user.valid?, "Expected user to be valid when service deems password strong: #{user.errors.full_messages}"
    end
  end

  test "invalid when password is weak per service" do
    weak_resp = PasswordStrengthClient::Response.new(ok: false, label: "WEAK", score: 0.12)

    with_stubbed_password_service(weak_resp) do
      user = User.new(email: "weak@example.com", password: "password", password_confirmation: "password")
      assert_not user.valid?, "Expected user to be invalid for weak password"
      assert_includes user.errors[:password], I18n.t('errors.messages.weak_password')
    end
  end
end
