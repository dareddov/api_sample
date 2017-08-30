class ProjectsCollection
  SORTABLE_FIELDS = [:name, :budget].sort.freeze

  include Rails.application.routes.url_helpers
  attr_reader :params
  attr_reader :projects

  def initialize(params)
    @params = params
    @projects = params[:sort] ? Project.order(sort_params).page(params[:page]) : Project.page(params[:page])
  end

  def to_json(_options = {})
    return bad_request if invalid_sortable_fields

    {
      data: data_projects,
      links: links
    }.to_json
  end

  def response_status
    invalid_sortable_fields ? :bad_request : :ok
  end

  def bad_request
    { title: 'Bad request', description: 'Not supported attribute by sorting!', status: '400' }.to_json
  end

  private

  def invalid_sortable_fields
    !((sort_params.keys.map(&:to_sym) + SORTABLE_FIELDS).uniq.sort == SORTABLE_FIELDS)
  end

  def sort_params
    SortParams.sorted_fields(params[:sort])
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
      self: projects_url(page: projects.current_page, sort: params[:sort])
    }

    links[:next] = projects_url(page: projects.next_page, sort: params[:sort]) if projects.next_page
    links[:previous] = projects_url(page: projects.prev_page, sort: params[:sort]) if projects.prev_page

    links
  end
end
