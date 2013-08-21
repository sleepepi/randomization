class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  serialize :email_notifications, Hash

  # Callbacks
  after_create :notify_system_admins

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  # Concerns
  include Contourable, Deletable

  # Named Scopes
  scope :current, -> { where deleted: false }
  scope :search, lambda { |arg| where( 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }

  # Model Validation
  validates_presence_of :first_name, :last_name

  # Model Relationships
  has_many :projects, -> { where deleted: false }


  def all_projects
    @all_projects ||= begin
      Project.current.where( user_id: self.id ) #.with_editor(self.id, true)
    end
  end

  def all_viewable_projects
    @all_viewable_projects ||= begin
      Project.current.where( user_id: self.id ) # .with_editor(self.id, [true, false])
    end
  end



  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def email_on?(value)
    [nil, true].include?(self.email_notifications[value.to_s])
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    super
  end

  def destroy
    super
    update_column :status, 'inactive'
    update_column :updated_at, Time.now
  end

  private

    def notify_system_admins
      User.current.system_admins.each do |system_admin|
        UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
      end
    end
end
