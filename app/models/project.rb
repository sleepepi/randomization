class Project < ActiveRecord::Base

  MAX_LISTS = 64
  BLOCK_SIZE_MULTIPLIERS = [1,2,3,4]

  serialize :config, Hash

  # Concerns
  include Deletable, Searchable

  # Named Scopes
  scope :with_editor, lambda { |*args| where('projects.user_id IN (?) or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.editor IN (?))', args.first, args.first, args[1] ).references(:project_users) }

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user
  has_many :assignments

  has_many :project_users
  has_many :users, -> { where( deleted: false ).order( 'last_name, first_name' ) }, through: :project_users
  has_many :editors, -> { where('project_users.editor = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.editor = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user

  # Project Methods

  def editable_by?(current_user)
    @editable_by ||= begin
      current_user.all_projects.where(id: self.id).count == 1
    end
  end

  def treatment_arms
    self.config[:treatment_arms] || []
  end

  def treatment_arms=(arms)
    self.config[:treatment_arms] = arms
  end

  def minimum_block_size
    self.treatment_arms.sum{ |arm| arm[:allocation].blank? ? 1 : arm[:allocation].to_i }
  end

  def block_size_multipliers
    (self.config[:block_size_multipliers] || {}).select{ |multiplier| multiplier[:allocation].to_i > 0 }
  end

  def block_size_multipliers=(multipliers)
    self.config[:block_size_multipliers] = multipliers
  end

  def combined_multipliers_size
    self.block_size_multipliers.sum{ |multiplier| multiplier[:value].to_i * multiplier[:allocation].to_i } * self.minimum_block_size
  end

  def block_groups_per_list
    self.combined_multipliers_size == 0 ? 0 : (self.randomization_goal / self.combined_multipliers_size.to_f).ceil
  end

  def get_block_group
    self.block_size_multipliers.collect{ |multiplier| [multiplier[:value].to_i] * multiplier[:allocation].to_i }.flatten
  end

  def get_block(block_size_multiplier)
    self.treatment_arms.collect{|arm| [arm[:name]] * (arm[:allocation].blank? ? 1 : arm[:allocation].to_i) }.flatten.compact * block_size_multiplier
  end

  def stratification_factors
    self.config[:stratification_factors] || []
  end

  def stratification_factors=(strata)
    self.config[:stratification_factors] = strata
  end

  def lists
    if self.number_of_lists > 0 and self.number_of_lists < MAX_LISTS
      if self.stratification_factors.size == 1
        (self.stratification_factors.first[:options] || []).collect{|i| [i]}
      else
        self.stratification_factors.collect{|stratum| (stratum[:options] || [])}.inject(:product)
      end
    else
      []
    end
  end

  def number_of_lists
    self.stratification_factors.collect{|stratum| (stratum[:options] || []).size}.inject(:*).to_i
  end

  def create_randomization!(subject_code, values, current_user, attested)
    list_name = values.join(', ')
    if subject_code.blank?
      self.errors.add(:subject_code, "can't be blank")
    elsif self.assignments.where( subject_code: subject_code ).size > 0
      self.errors.add(:subject_code, "has already been randomized")
    end
    if values.size != self.stratification_factors.size
      self.errors.add(:stratification_factors, "must be selected")
    elsif self.assignments.where( list_name: list_name ).size == 0
      self.errors.add(:list, "#{list_name} does not exist")
    elsif self.assignments.where( list_name: list_name, subject_code: nil ).size == 0
      self.errors.add(:list, "#{list_name} is already full")
    end
    unless attested
      self.errors.add(:attested, "must be checked")
    end

    return nil if self.errors.size > 0

    assignment = self.assignments.where( list_name: list_name, subject_code: nil ).first
    if assignment
      assignment.update( subject_code: subject_code, randomized_at: Time.now, user_id: current_user.id, attested: attested )
      users_to_email = (self.users + [self.user]).uniq
      users_to_email.each do |user_to_email|
        UserMailer.subject_randomized(assignment, user_to_email).deliver_later if Rails.env.production? and user_to_email.email_on?(:send_email)
      end
    end
    assignment
  end

  def generate_lists!
    return if self.randomizations.size > 0
    self.assignments.destroy_all
    block_group = self.get_block_group
    self.lists.each do |list|
      block_ordering = []
      (1..self.block_groups_per_list).each do
        block_ordering << block_group.shuffle
      end
      entry_index = 0
      block_ordering.each_with_index do |multipliers, index|
        multipliers.each do |multiplier|
          self.get_block(multiplier).shuffle.each do |arm|
            entry_index += 1
            self.assignments.create(
              list_name: list.join(', '),
              position: entry_index,
              treatment_arm: arm,
              block_group: index,
              multiplier: multiplier
            )
          end
        end
      end
    end
  end

  def randomizations
    self.assignments.where( "subject_code IS NOT NULL" )
  end
end
