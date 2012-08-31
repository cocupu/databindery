Cocupu::Application.routes.draw do

  devise_for :users, class_name: "LoginCredential"
  as :user do
    get "signin", :to => "devise/sessions#new"
    post "signin", :to => "devise/sessions#create"
    get "signout", :to => "devise/sessions#destroy"
  end
  
  resources :drives
  resources :pools do
    resources :models, :only=>:create do
      resources :nodes, :only=>[] do
        collection do
          get 'search'
        end
      end
    end
    resources :nodes, :only=>[:create] do
      collection do
        get 'search'
      end
    end
  end

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
  
  resources :models, :except=>:create do
    resources :fields
    resources :associations, :only=>:create
    resources :nodes 
  end


  resources :file_entities

  resources :nodes, :except=>[:create] do
    resources :associations, :only=>[:index, :create]
  end

  resources :exhibits 

  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
