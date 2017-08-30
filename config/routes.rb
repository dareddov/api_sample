Rails.application.routes.draw do
  resources :projects, only: %i[index show], constraints: { format: 'json' }
end
