class Identity < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :login_credential
  has_many :pools, :foreign_key=>'owner_id', :dependent => :destroy
  has_many :models, :foreign_key=>'identity_id', :dependent => :destroy
  has_many :mapping_templates, :dependent => :destroy
  has_many :google_accounts, :foreign_key=>'owner_id', :dependent => :destroy
  has_many :chattels, :foreign_key=>'owner_id', :dependent => :destroy

  validates :short_name, :presence=>true, :uniqueness=>true, :format=>{:with=>/\A\w+[\w-]+\z/,
    :message => "may only contain alphanumeric characters or dashes and cannot begin with a dash" }

  def short_name=(val)
    write_attribute(:short_name, val.downcase)
  end

  def to_param
    short_name
  end
  

end
