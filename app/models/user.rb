class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true,
                    format: {
                      with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}\z/
                    }
  validates :name, presence: true
  validates :gender, presence: true
  validate :gender_correct_value
  validates :birthday, presence: true
  validate :birthday_correct_value
  validates :password, confirmation: true, if: :password_changed?
  validates :password_confirmation, presence: true, if: :password_changed?

  has_many :redemptions, dependent: :destroy
  has_one :facebook_auth, dependent: :destroy

  before_save :encrypt_password

  def self.authenticate(email, password)
    user = User.find_by(email: email)
    return nil unless user
    return user if user.password == User.encrypt(password, user.salt)
  end

  def active_redemptions
    redemptions.where(redeemed: false).count
  end

  def facebook_token
    facebook_auth&.token
  end

  def facebook_id
    facebook_auth&.facebook_id
  end

  private

  def encrypt_password
    if new_record?
      self.salt = generate_salt
      self.password = User.encrypt(password, salt)
    end
  end

  def self.encrypt(password, salt)
    Digest::SHA2.hexdigest("#{password}#{salt}")
  end

  def generate_salt
    Digest::SHA2.hexdigest("#{SecureRandom.hex(8)}Nower#{Time.current}")
  end

  def gender_correct_value
    unless %w[m f].include?(gender)
      errors.add(:gender, I18n.t('errors.user.gender.is_invalid'))
    end
  end

  def birthday_correct_value
    return unless birthday

    if birthday > 12.years.ago
      errors.add(:birthday, I18n.t('errors.user.birthday.too_young'))
    end

    if birthday < 100.years.ago
      errors.add(:birthday, I18n.t('errors.user.birthday.too_old'))
    end
  end
end
