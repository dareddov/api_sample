class ProjectsController < ApplicationController
  def index
    projects_collection = ProjectsCollection.new(params)

    render json: projects_collection, status: projects_collection.response_status
  end
end
