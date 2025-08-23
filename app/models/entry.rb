class Entry < ApplicationRecord
  belongs_to :user

  validates :name, :username, :password, presence: true
  validate :url_must_be_valid

  encrypts :username, deterministic: true
  encrypts :password

  private

  def url_must_be_valid
    unless url.to_s.start_with?("http://", "https://")
      errors.add(:url, "must start with http:// or https://")
    end
  end
end
