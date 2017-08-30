class Project < ActiveRecord::Base
  paginates_per Rails.env.test? ? 2 : 20
end
