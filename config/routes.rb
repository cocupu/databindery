Cocupu::Application.routes.draw do

  devise_for :users, class_name: "LoginCredential"
  as :user do
    get "signin", :to => "devise/sessions#new"
    post "signin", :to => "devise/sessions#create"
    get "signout", :to => "devise/sessions#destroy"
  end


  # Drives is a redirect point for google oauth, so it can't have any dynamic segments
  resources :drives, :only=>[:index]
  
  resources :identities, :path=>'', :only=>[] do
    resources :file_entities
    resources :chattels
    resources :pools do
      resources :exhibits 
      resources :drives, :only=>[:index] do
        collection do
          get 'spawn'
        end
      end
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
      resources :mapping_templates
      resources :spreadsheets do
        resources :worksheets do
        end
      end
      resources :chattels, :only=>[] do
        member do
          get 'describe'
        end
      end
    end
  end

  
  resources :models, :except=>:create do
    resources :fields
    resources :associations, :only=>:create
    resources :nodes 
  end


  resources :nodes, :except=>[:create] do
    resources :associations, :only=>[:index, :create]
  end


  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
