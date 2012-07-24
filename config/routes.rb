Cocupu::Application.routes.draw do

  devise_for :login_credentials do
    get 'signin' => 'devise/sessions#new', :as => :new_user_session
    post 'signin' => 'devise/sessions#create', :as => :user_session
    get 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
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
  
  resources :models do
    resources :nodes
  end

  resources :exhibits 

  resources :jobs
  resources :job_log_items
  resources :spreadsheet_rows
  root :to => 'welcome#index'

end
