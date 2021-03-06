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
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_project, lambda { |*args| where("users.id in (select projects.user_id from projects where projects.id IN (?) and projects.deleted = ?) or users.id in (select project_users.user_id from project_users where project_users.project_id IN (?) and project_users.editor IN (?))", args.first, false, args.first, args[1] ) }

  # Model Validation
  validates_presence_of :first_name, :last_name

  # Model Relationships
  has_many :projects, -> { where deleted: false }


  def all_projects
    @all_projects ||= begin
      Project.current.with_editor(self.id, true)
    end
  end

  def all_viewable_projects
    @all_viewable_projects ||= begin
      Project.current.with_editor(self.id, [true, false])
    end
  end

  def associated_users
    User.where( deleted: false ).with_project(self.all_projects.pluck(:id), [true, false])
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
    super and not self.deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.now
  end

  private

    def notify_system_admins
      User.current.where( system_admin: true ).each do |system_admin|
        UserMailer.notify_system_admin(system_admin, self).deliver_later if Rails.env.production?
      end
    end
end
