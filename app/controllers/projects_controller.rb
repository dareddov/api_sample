class ProjectsController < ApplicationController
  def index
    projects = Project.page(params[:page])
    projects_collection = ProjectsCollection.new(projects)

    render json: projects_collection
  end
end
