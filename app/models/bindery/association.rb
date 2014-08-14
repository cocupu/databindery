class Bindery::Association
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