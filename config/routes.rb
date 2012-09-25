Cocupu::Application.routes.draw do

  devise_for :users, class_name: "LoginCredential", controllers: {registrations:  "users/registrations"}
  as :user do
    get "signin", :to => "devise/sessions#new"
    post "signin", :to => "devise/sessions#create"
    get "signout", :to => "devise/sessions#destroy"
  end

  # Drives is a redirect point for google oauth, so it can't have any dynamic segments
  resources :drives, :only=>[:index]

  
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
  
  #jasmine is the path of our testing library so, we have restricted identities from begining with 'jasmine'
  constraints = {:id=>/(?!jasmine)[^\/]*/} unless Rails.env.production?
  resources :identities, :path=>'', :only=>[], :constraints=>constraints do
    resources :file_entities
    resources :chattels
    resources :pools, :path=>'' do
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

end
