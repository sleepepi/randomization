class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project,          only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project,      only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_assignment,                only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_assignment,   only: [ :show, :edit, :update, :destroy ]

  # GET /assignments
  # GET /assignments.json
  def index
    @order = scrub_order(Assignment, params[:order], "assignments.randomized_at, assignments.id")
    @assignments = @project.assignments.order(@order).page(params[:page]).per( 20 )
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  # # GET /assignments/new
  # def new
  #   @assignment = Assignment.new
  # end

  # # GET /assignments/1/edit
  # def edit
  # end

  # # POST /assignments
  # # POST /assignments.json
  # def create
  #   @assignment = Assignment.new(assignment_params)

  #   respond_to do |format|
  #     if @assignment.save
  #       format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @assignment }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @assignment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PUT /assignments/1
  # # PUT /assignments/1.json
  # def update
  #   respond_to do |format|
  #     if @assignment.update(assignment_params)
  #       format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @assignment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.update( subject_code: nil, randomized_at: nil )

    respond_to do |format|
      format.html { redirect_to [@project, @assignment], notice: 'Randomization was successfully removed.' }
      format.json { render action: 'show', status: :created, location: @assignment }
      format.js
    end
  end

  private

    def set_assignment
      @assignment = @project.assignments.find(params[:id])
    end

    def redirect_without_assignment
      empty_response_or_root_path(project_assignments_path(@project)) unless @assignment
    end

    def assignment_params
      params[:assignment] ||= {}
      params.require(:assignment).permit(
        # :project_id, :list_name, :block_group, :multiplier, :position, :treatment_arm, :subject_code, :randomized_at
      )
    end

end
