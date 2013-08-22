class Project < ActiveRecord::Base

  MAX_LISTS = 64
  BLOCK_SIZE_MULTIPLIERS = [1,2,3,4]

  serialize :config, Hash

  # Concerns
  include Deletable, Searchable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user

  # Project Methods

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
      self.stratification_factors.collect{|stratum| (stratum[:options] || [])}.inject(:product)
    else
      []
    end
  end

  def number_of_lists
    self.stratification_factors.collect{|stratum| (stratum[:options] || []).size}.inject(:*).to_i
  end

  def randomization_goal
    80
  end

  def seed
    "myseed"
  end
end
