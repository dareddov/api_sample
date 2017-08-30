class SingleProject
  include Rails.application.routes.url_helpers
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def to_json(_options = {})
    {
      data: {
        type: project.model_name.plural,
        id: project.id,
          attributes: {
            name: project.name,
            customer_name: project.customer_name,
            budget: project.budget,
            technologies: project.technologies
          }
      },
      links: {
        self: project_url(project)
      }
    }.to_json
  end
end