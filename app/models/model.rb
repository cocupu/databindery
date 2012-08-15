class Model < ActiveRecord::Base

  class Association
    INBOUND = ['Has Many', 'Has One']
    OUTBOUND = ['Ordered List', 'Unordered List']
    TYPES = INBOUND + OUTBOUND
    instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }
    def initialize(data)
      @data = data
    end

    def data
      @data
    end

    def label
      @label ||= "#{type} #{name.capitalize}"
    end


    def model
      @model ||= Model.find(@data[:references])
    end

    private
    def method_missing(method, *args)
      if @data.has_key?(method)
        @data[method]
      elsif @data.respond_to?(method)
        if block_given?
          @data.send(method, *args)  { |*block_args| yield(*block_args) }
        else
          @data.send(method, *args)
        end
      else
        message = "undefined method `#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
        raise NoMethodError, message
      end
    end
  end

  class AssociationSet
    instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }
    
    def initialize(data)
      @target = data.map { |d| Association.new(d) }
    end

    def target
      @target
    end

    private
    def method_missing(method, *args)
      unless @target.respond_to?(method)
        message = "undefined method `#{method.to_s}' for \"#{@target}\":#{@target.class.to_s}"
        raise NoMethodError, message
      end

      if block_given?
        @target.send(method, *args)  { |*block_args| yield(*block_args) }
      else
        @target.send(method, *args)
      end
    end
  end
  serialize :fields, Array 
  serialize :associations, Array 

  after_initialize :init

  validates :name, :presence=>true
  has_many :nodes

  belongs_to :owner, class_name: "Identity", :foreign_key => 'identity_id'
  validates :owner, presence: true

  validates :label, :inclusion => {:in=> lambda {|foo| foo.keys }, :message=>"must be a field"}, :if=>Proc.new { |a| a.label }

  def init
    self.fields ||= []
    self.associations ||= []
  end

  def index
    ## only index the most recent version of each node
    max_ids = Node.select('max(id) as max_id').where('model_id = ?', self.id).group(:persistent_id).map(&:max_id)
    Cocupu.index(Node.find(max_ids).map {|m| m.to_solr })
  end

  def keys
    fields.map{|f| f[:code]}
  end

  def self.field_name(label)
    label.downcase.gsub(/\s+/, '_')
  end

  def inbound_associations
    @inbound ||= AssociationSet.new(associations.select {|assoc| Association::INBOUND.include?(assoc[:type]) })
  end

  def outbound_associations
    @outbound ||= AssociationSet.new(associations.select {|assoc| Association::OUTBOUND.include?(assoc[:type]) })
  end

  
end
