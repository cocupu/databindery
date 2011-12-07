class JobLogItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status
  field :name
  field :message

end
