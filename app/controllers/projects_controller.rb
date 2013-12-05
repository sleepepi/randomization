class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :show, :randomize_subject, :create_randomization, :randomizations ]
  before_action :set_editable_project, only: [ :edit, :update, :destroy, :generate_lists ]
  before_action :redirect_without_project, only: [ :show, :edit, :update, :destroy, :generate_lists, :randomize_subject, :create_randomization, :randomizations ]

  # GET /projcets/1/randomizations
  def randomizations
    @order = scrub_order(Assignment, params[:order], "assignments.randomized_at DESC")
    @assignments = @project.randomizations.order(@order).page(params[:page]).per( 20 )
  end

  # GET /projects/1/randomize_subject
  def randomize_subject
  end

  # POST /projects/1/create_randomization
  def create_randomization
    stratum_keys = params.keys.select{|key| key =~ /^stratum_[\d]*$/}
    values = params.each.select{|key, value| stratum_keys.include?(key)}.collect{|k,v| v}.compact

    if @assignment = @project.create_randomization!(params[:subject_code], values, current_user)
      redirect_to [@project, @assignment], notice: "Subject successfully randomized to <b>#{@assignment.treatment_arm}</b>.".html_safe
    else
      render action: 'randomize_subject'
    end
  end

  # POST /projects/add_treatment_arm.js
  def add_treatment_arm
  end

  # POST /projects/add_stratification_factor.js
  def add_stratification_factor
  end

  # POST /projects/1/generate_lists.js
  def generate_lists
    @project.generate_lists!
  end

  # GET /projects
  # GET /projects.json
  def index
    flash.delete(:notice)
    @order = scrub_order(Project, params[:order], "projects.name")
    @projects = current_user.all_viewable_projects.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = current_user.projects.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.json { head :no_content }
    end
  end

  private

    # Overwriting application_controller
    def set_viewable_project
      super(:id)
      # @project = current_user.all_viewable_and_site_projects.find_by_id(params[:id])
    end

    # Overwriting application_controller
    def set_editable_project
      super(:id)
      # @project = current_user.all_projects.find_by_id(params[:id])
    end

    def redirect_without_project
      super(projects_path)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(
        :name,
        :description,
        :randomization_goal,
        { treatment_arms: [ :name, :allocation ] },
        { stratification_factors: [ :name, options: [] ] },
        { block_size_multipliers: [ :value, :allocation ] }
      )
    end
end
