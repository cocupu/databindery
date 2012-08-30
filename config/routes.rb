Cocupu::Application.routes.draw do

  devise_for :users, class_name: "LoginCredential"
  as :user do
    get "signin", :to => "devise/sessions#new"
    post "signin", :to => "devise/sessions#create"
    get "signout", :to => "devise/sessions#destroy"
  end
  
  resources :drives
  resources :pools

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
    resources :fields
    resources :associations, :only=>:create
    resources :nodes do
      collection do
        get 'search'
      end
    end
  end


  resources :file_entities

  resources :nodes do
    resources :associations, :only=>[:index, :create]
    collection do
      get 'search'
    end
  end

  resources :exhibits 

  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
