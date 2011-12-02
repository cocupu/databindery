class ModelInstance
  include Mongoid::Document
  belongs_to :model
  validates_presence_of :model

  # keys are refs to model.m_fields 
  has_many :properties

end
