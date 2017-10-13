class ProjectForm < Patterns::Form
  attribute :name, String
  attribute :customer_name, String
  attribute :budget, Decimal
  attribute :technologies, String

  validates :name, :budget, presence: true
  validates :budget, numericality: { greater_than: 0 }

  private

  def persist
    create_project
  end

  def create_project
    resource.assign_attributes(attributes)
    resource.save
  end
end
