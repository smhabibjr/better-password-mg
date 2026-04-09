class Entry < ApplicationRecord
  belongs_to :user
  validates :name, :url, :username, :password, presence: true
  validate :url_must_be_valid

  encrypts :username, deterministic: true
  encrypts :password

   scope :search_name, ->(name) {
    where("entries.name ILIKE ?", "%#{name}%") if name.present?
  }

  def self.search(name)
    search_name(name).order(:name)
  end

  private
  def url_must_be_valid
    uri = URI.parse(url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid URL")
  end
end
