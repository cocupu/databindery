Bindery::Application.routes.draw do


  match "bookmarks/clear", :to => "bookmarks#clear", :as => "clear_bookmarks"
  resources :bookmarks

  devise_for :users, class_name: "LoginCredential", controllers: {registrations:  "users/registrations"}
  as :user do
    get "signin", :to => "devise/sessions#new"
    post "signin", :to => "devise/sessions#create"
    get "signout", :to => "devise/sessions#destroy"
  end

  # Drives is a redirect point for google oauth, so it can't have any dynamic segments
  resources :drives, :only=>[:index]
  
  resources :models, :except=>[:create, :index] do
    resources :fields
    resources :associations, :only=>:create
    #resources :nodes 
  end


  resources :nodes, :only=>[] do
    resources :associations, :only=>[:index, :create]
  end


  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

  namespace :api do
    namespace :v1 do
      resources :tokens,:only => [:create, :destroy]
    end
  end
  
  
  resources :identities, :only=>:index

  #jasmine is the path of our testing library so, we have restricted identities from begining with 'jasmine'
  constraints = {:id=>/(?!jasmine)[^\/\.]*/} unless Rails.env.production?
  resources :identities, :path=>'', :only=>[], :constraints=>constraints do
    resources :file_entities
    resources :chattels
    match 'exhibits/:exhibit_id' => 'catalog#index', :as => 'exhibit'
    resources :exhibits, :only=>[] do
      resources :solr_document, :path => '', :controller => 'catalog', :only => [:show, :update]
    end

    match ':pool_id/search' => 'pool_searches#index', :as => 'pool_search'
    
    resources :pools, :path=>'' do
      resources :exhibits, :except=>[:show]
      # can't do :path => '' because that breaks models, nodes, etc. in client api
      resources :solr_document, :path => 'results', :controller => 'pool_searches', :only => [:show, :update]
      resources :drives, :only=>[:index] do
        collection do
          get 'spawn'
        end
      end
      resources :models, :only=>[:create, :index] do
        resources :nodes, :only=>[] do
          collection do
            get 'search'
          end
        end
      end
      resources :nodes, :only=>[:create, :update, :show, :new, :index, :destroy] do
        collection do
          get 'search'
          post 'find_or_create'
        end
        match 'files' => 'nodes#attach_file', :via=>:post
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
