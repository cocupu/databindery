class LoginCredential < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :identities_attributes

  has_many :identities, :dependent => :destroy

  accepts_nested_attributes_for :identities

  after_initialize :create_identity
  before_validation :remove_blank_identities

  def remove_blank_identities
    identities.reject!{|ident| ident.short_name.nil? }
  end

  def create_identity
    identities.build if identities.empty?
  end


end
