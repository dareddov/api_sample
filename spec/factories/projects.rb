FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}"}
    sequence(:customer_name) { |n| "Customer #{n}"}
    sequence(:budget) { rand(100) }
    sequence(:technologies) { %w[ruby php angular react dot_net elixir ember].sample(2) }
  end
end