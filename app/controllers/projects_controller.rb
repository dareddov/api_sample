class ProjectsController < ApplicationController
  def index
    projects = Project.page(params[:page])
    projects_collection = ProjectsCollection.new(projects)

    render json: projects_collection
  end

  def create
    form = ProjectForm.new(Project.new, project_attributes)

    if form.save
      project = Project.find(form.to_param)
      render json: SingleProject.new(project), status: :created
    else
      render json: ErrorSerializer.new(form), status: :bad_request
    end
  end

  private

  def project_attributes
    params[:data].require(:attributes).permit(:name, :customer_name, :budget, technologies: [])
  end
end
