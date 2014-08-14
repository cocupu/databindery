class Bindery::AssociationSet
  instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }

  def initialize(data)
    @target = data.map { |d| Bindery::Association.new(d) }
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