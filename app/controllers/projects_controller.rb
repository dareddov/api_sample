class ProjectsController < ApplicationController
  def index
    projects = Project.page(params[:page])
    projects_collection = ProjectsCollection.new(projects)

    render json: projects_collection
  end

  def show
    project = Project.find_by!(id: params[:id])
    single_project = SingleProject.new(project)

    render json: single_project

  rescue ActiveRecord::RecordNotFound => e
    render json: { title: 'Not found', description: 'The project was not found', status: '404' }, status: :not_found
  end
end
