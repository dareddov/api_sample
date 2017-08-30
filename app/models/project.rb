class Project < ActiveRecord::Base
  paginates_per ENV.fetch('page_size')
end
