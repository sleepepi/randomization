class Project < ActiveRecord::Base

  MAX_LISTS = 128

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

  def stratification_factors
    self.config[:stratification_factors] || []
  end

  def stratification_factors=(strata)
    self.config[:stratification_factors] = strata
  end

  def lists
    if self.number_of_lists < MAX_LISTS
      self.stratification_factors.collect{|stratum| (stratum[:options] || [])}.inject(:product)
    else
      []
    end
  end

  def number_of_lists
    self.stratification_factors.collect{|stratum| (stratum[:options] || []).size}.inject(:*)
  end
end
