Cocupu::Application.routes.draw do

  resources :chattels do
    member do
      get 'describe'
    end
  end
  resources :spreadsheets do
    resources :worksheets do
    end
  end
  resources :mapping_templates
  
  resources :models do
    resources :model_instances
  end
  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
