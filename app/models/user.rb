class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # if we delete the user, also delete everything belongs to it.
  has_many :entries, dependent: :destroy

  validate :password_strength_check, if: :password_required_for_strength_check?

  private

  def password_required_for_strength_check?
    # Run when setting a new password (on create) or updating the password
    password.present?
  end

  def password_strength_check
    resp = PasswordStrengthClient.check(password)
    return if resp.ok

    errors.add(:password, I18n.t('errors.messages.weak_password', default: 'is too weak'))
  end
end
