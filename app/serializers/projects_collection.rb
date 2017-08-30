class ProjectsCollection
  include Rails.application.routes.url_helpers
  attr_reader :projects

  def initialize(projects)
    @projects = projects
  end

  def to_json(_options = {})
    {
      data: data_projects,
      links: links
    }.to_json
  end

  def data_projects
    projects.map do |project|
      {
        name: project.name,
        customer_name: project.customer_name,
        budget: project.budget,
        technologies: project.technologies
      }
    end
  end

  def links
    links = {
      self: projects_url(page: projects.current_page)
    }

    links[:next] = projects_url(page: projects.next_page) if projects.next_page
    links[:previous] = projects_url(page: projects.prev_page) if projects.prev_page

    links
  end
end
