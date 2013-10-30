# RailsAdmin config file. Generated on October 30, 2013 13:14
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  #config.authorize_with :cancan

  config.authorize_with do |controller|
    puts "Identity: #{current_identity.short_name}"
    redirect_to main_app.root_path unless (current_identity.short_name == "matt" || current_identity.short_name == "matt_zumwalt")
  end

  # If you want to track changes on your models:
  # config.audit_with :history, LoginCredential

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, LoginCredential

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Bindery', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [AccessControl, Bindery::Spreadsheet, Bookmark, ChangeSet, Chattel, ConcurrentJob, Exhibit, GoogleAccount, Identity, JobLogItem, LoginCredential, MappingTemplate, Model, Node, Pool, S3Connection, Search, SearchFilter, SpreadsheetRow, Worksheet]

  # Add models here if you want to go 'whitelist mode':
  # config.included_models = [AccessControl, Bindery::Spreadsheet, Bookmark, ChangeSet, Chattel, ConcurrentJob, Exhibit, GoogleAccount, Identity, JobLogItem, LoginCredential, MappingTemplate, Model, Node, Pool, S3Connection, Search, SearchFilter, SpreadsheetRow, Worksheet]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model AccessControl do
  #   # Found associations:
  #     configure :pool, :belongs_to_association
  #     configure :identity, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :pool_id, :integer         # Hidden
  #     configure :identity_id, :integer         # Hidden
  #     configure :access, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Bindery::Spreadsheet do
  #   # Found associations:
  #     configure :pool, :belongs_to_association
  #     configure :model, :belongs_to_association
  #     configure :spawned_from_datum, :belongs_to_association
  #     configure :modified_by, :belongs_to_association
  #     configure :worksheets, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :data, :serialized
  #     configure :persistent_id, :string
  #     configure :parent_id, :string
  #     configure :pool_id, :integer         # Hidden
  #     configure :identity_id, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :model_id, :integer         # Hidden
  #     configure :binding, :string
  #     configure :associations, :serialized
  #     configure :spawned_from_node_id, :integer
  #     configure :spawned_from_datum_id, :integer         # Hidden
  #     configure :modified_by_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Bookmark do
  #   # Found associations:
  #   # Found columns:
  #     configure :id, :integer
  #     configure :user_id, :integer
  #     configure :document_id, :string
  #     configure :title, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :user_type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ChangeSet do
  #   # Found associations:
  #     configure :pool, :belongs_to_association
  #     configure :previous, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :data, :text
  #     configure :pool_id, :integer         # Hidden
  #     configure :identity_id, :integer
  #     configure :parent_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Chattel do
  #   # Found associations:
  #     configure :owner, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :attachment_content_type, :string
  #     configure :attachment_file_name, :string
  #     configure :attachment_extension, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :owner_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ConcurrentJob do
  #   # Found associations:
  #     configure :parent, :belongs_to_association
  #     configure :children, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :status, :string
  #     configure :name, :string
  #     configure :message, :text
  #     configure :data, :serialized
  #     configure :parent_id, :integer         # Hidden
  #     configure :type, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Exhibit do
  #   # Found associations:
  #     configure :pool, :belongs_to_association
  #     configure :filters, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :title, :string
  #     configure :facets, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :pool_id, :integer         # Hidden
  #     configure :index_fields, :serialized   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model GoogleAccount do
  #   # Found associations:
  #     configure :owner, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :owner_id, :integer         # Hidden
  #     configure :profile_id, :string
  #     configure :email, :string
  #     configure :refresh_token, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Identity do
  #   # Found associations:
  #     configure :login_credential, :belongs_to_association
  #     configure :pools, :has_many_association
  #     configure :exhibits, :has_many_association
  #     configure :models, :has_many_association
  #     configure :mapping_templates, :has_many_association
  #     configure :google_accounts, :has_many_association
  #     configure :chattels, :has_many_association
  #     configure :changes, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :login_credential_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :short_name, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model JobLogItem do
  #   # Found associations:
  #     configure :parent, :belongs_to_association
  #     configure :children, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :status, :string
  #     configure :name, :string
  #     configure :message, :text
  #     configure :data, :serialized
  #     configure :parent_id, :integer         # Hidden
  #     configure :type, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model LoginCredential do
  #   # Found associations:
  #     configure :bookmarks, :has_many_association
  #     configure :searches, :has_many_association
  #     configure :identities, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :email, :string
  #     configure :password, :password         # Hidden
  #     configure :password_confirmation, :password         # Hidden
  #     configure :reset_password_token, :string         # Hidden
  #     configure :reset_password_sent_at, :datetime
  #     configure :remember_created_at, :datetime
  #     configure :sign_in_count, :integer
  #     configure :current_sign_in_at, :datetime
  #     configure :last_sign_in_at, :datetime
  #     configure :current_sign_in_ip, :string
  #     configure :last_sign_in_ip, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :authentication_token, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model MappingTemplate do
  #   # Found associations:
  #     configure :owner, :belongs_to_association
  #     configure :pool, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :row_start, :integer
  #     configure :model_mappings, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :file_type, :string
  #     configure :identity_id, :integer         # Hidden
  #     configure :pool_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Model do
  #   # Found associations:
  #     configure :owner, :belongs_to_association
  #     configure :pool, :belongs_to_association
  #     configure :node, :has_many_association
  #     configure :nodes, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :fields, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :label, :string
  #     configure :identity_id, :integer         # Hidden
  #     configure :associations, :serialized
  #     configure :pool_id, :integer         # Hidden
  #     configure :code, :string
  #     configure :allow_file_bindings, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Node do
  #   # Found associations:
  #     configure :pool, :belongs_to_association
  #     configure :model, :belongs_to_association
  #     configure :spawned_from_datum, :belongs_to_association
  #     configure :modified_by, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :data, :serialized
  #     configure :persistent_id, :string
  #     configure :parent_id, :string
  #     configure :pool_id, :integer         # Hidden
  #     configure :identity_id, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :model_id, :integer         # Hidden
  #     configure :binding, :string
  #     configure :associations, :serialized
  #     configure :spawned_from_node_id, :integer
  #     configure :spawned_from_datum_id, :integer         # Hidden
  #     configure :modified_by_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Pool do
  #   # Found associations:
  #     configure :owner, :belongs_to_association
  #     configure :chosen_default_perspective, :belongs_to_association
  #     configure :exhibits, :has_many_association
  #     configure :nodes, :has_many_association
  #     configure :models, :has_many_association
  #     configure :mapping_templates, :has_many_association
  #     configure :s3_connections, :has_many_association
  #     configure :access_controls, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :owner_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :head_id, :integer
  #     configure :short_name, :string
  #     configure :description, :text
  #     configure :chosen_default_perspective_id, :integer         # Hidden
  #     configure :persistent_id, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model S3Connection do
  #   # Found associations:
  #     configure :pool, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :pool_id, :integer         # Hidden
  #     configure :access_key_id, :string
  #     configure :secret_access_key, :string
  #     configure :max_file_size, :integer
  #     configure :acl, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Search do
  #   # Found associations:
  #   # Found columns:
  #     configure :id, :integer
  #     configure :query_params, :serialized
  #     configure :user_id, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :user_type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model SearchFilter do
  #   # Found associations:
  #     configure :exhibit, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :field_name, :string
  #     configure :operator, :string
  #     configure :values, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :exhibit_id, :integer         # Hidden
  #     configure :association_code, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model SpreadsheetRow do
  #   # Found associations:
  #     configure :worksheet, :belongs_to_association
  #     configure :job_log_item, :has_one_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :row_number, :integer
  #     configure :worksheet_id, :integer         # Hidden
  #     configure :values, :serialized
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Worksheet do
  #   # Found associations:
  #     configure :spreadsheet, :belongs_to_association
  #     configure :rows, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :spreadsheet_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :order, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end