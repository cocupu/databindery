#!/usr/bin/env ruby

require 'httparty'

HOST = "localhost:8080"

class Bindery
  include HTTParty
  attr_accessor :token

  class Identity
    attr_accessor :values, :token
    def initialize(values, token)
      self.token = token
      self.values = values
    end

    def short_name
      values["short_name"]
    end

    def url
      values["url"]
    end

    def pools
      return @pools if @pools
      req_url = "http://#{HOST}#{url}.json?auth_token=#{token}"
      puts "Calling #{req_url}"
      response = Bindery.get(req_url)
      raise "Error getting pools: #{response}" unless response.code == 200
      @pools = response.map {|val| Pool.new(val, token)}
    end

    def pool(short_name)
      pools.find{|i| i.short_name == short_name}
    end

  end

  class Pool
    attr_accessor :values, :token
    def initialize(values, token)
      self.token = token
      self.values = values
    end
    def short_name
      values["short_name"]
    end

    def url
      values["url"]
    end

    def models
      return @models if @models
      req_url = "http://#{HOST}#{url}/models.json?auth_token=#{token}"
      puts "Calling #{req_url}"
      response = Bindery.get(req_url)
      #puts "RESP: #{response}"
      raise "Error getting models: #{response}" unless response.code == 200
      @pools = response.map {|val| Model.new(val, token)}
    end

  end

  class Model
    attr_accessor :values, :token
    def initialize(values, token)
      self.token = token
      self.values = values
    end

    def name
      values['name']
    end

    def identity
      values['identity']
    end

    def pool
      values['pool']
    end

    def url
      values['url'] || "/#{identity}/#{pool}/models"
    end

    def url=(url)
      values['url'] = url
    end

    def id=(id)
      values['id'] = id
    end

    def fields=(fields)
      values['fields'] = fields
    end

    def id
      values['id']
    end

    def save
      req_url = "http://#{HOST}#{url}.json?auth_token=#{token}"
      response = if id
        Bindery.put(req_url, body: {model: values})
      else
        Bindery.post(req_url, body: {model: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['id'])
        self.id = response['id']
        self.url = response['url']
      end
      values
    end

  end

  class Node
    attr_accessor :values, :token
    def initialize(values, token)
      self.token = token
      self.values = values
    end

    def model_id
      values['model_id']
    end

    def url
      values['url'] || "/models/#{model_id}/nodes"
    end

    def url=(url)
      values['url'] = url
    end

    def persistent_id=(id)
      values['persistent_id'] = id
    end

    def fields=(fields)
      values['fields'] = fields
    end

    def persistent_id
      values['persistent_id']
    end

    def save
      req_url = "http://#{HOST}#{url}.json?auth_token=#{token}"
      puts "Req url: #{req_url}"
      response = if persistent_id
        Bindery.put(req_url, body: {node: values})
      else
        Bindery.post(req_url, body: {node: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['id'])
        self.persistent_id = response['persistent_id']
        self.url = response['url']
      end
      values
    end

  end

  def initialize(email, password)
    response = self.class.post("http://#{HOST}/api/v1/tokens", body: {email: email, password: password})
    raise "Error logging in: #{response}" unless response.code == 200
    self.token = response["token"]
  end

  def identities
    return @identities if @identities
    response = self.class.get("http://#{HOST}/identities?auth_token=#{token}")
    raise "Error getting identities: #{response}" unless response.code == 200
    @identities = response.map {|val| Identity.new(val, token)}
  end

  def identity(short_name)
    identities.find{|i| i.short_name == short_name}
  end

end
 
b = Bindery.new('jcoyne@justincoyne.com', 'foobar')
# puts "\npools:\n" + b.identity('herp').pools.inspect
# puts "\n\nmodels:\n " + b.identity('herp').pool('hob-bies').models.inspect
# 
# puts "\n\nSaving a new one..."
# m = Bindery::Model.new({'identity' =>'herp', 'pool'=>'hob-bies', 'name'=>"Cars"}, b.token)
# m.save
# puts "\n\nModel:\n" + m.inspect
# m.fields = [{"name"=>"Name", "type"=>"text", "uri"=>"", "code"=>"name"}, {"name"=>"Date Completed", "type"=>"text", "uri"=>"", "code"=>"date_completed"}]
# puts "\n\nUpdating ..."
# m.save 
# puts m.inspect

m = Bindery::Model.new({'id' =>'72'}, b.token)

n = Bindery::Node.new({'model_id' => m.id, 'data' => {"name"=>"Ferrari", "date_completed"=>"Nov 10, 2012"}}, b.token)
n.save
puts n.inspect





