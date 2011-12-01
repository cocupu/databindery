Cocupu::Application.routes.draw do

  resources :chattels do
    member do
      get 'describe'
    end
  end
  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
