#!/usr/bin/env ruby

require 'httparty'

class Bindery
  include HTTParty
  attr_accessor :token, :host, :port

  class Identity
    attr_accessor :values, :conn
    def initialize(values, conn)
      self.conn = conn
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
      response = conn.get(url+'.json')
      raise "Error getting pools: #{response}" unless response.code == 200
      @pools = response.map {|val| Pool.new(val, conn)}
    end

    def pool(short_name)
      pools.find{|i| i.short_name == short_name}
    end

  end

  class Pool
    attr_accessor :values, :conn
    def initialize(values, conn)
      self.conn = conn
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
      # req_url = "http://#{host}:#{port}#{url}/models.json?auth_token=#{token}"
      # puts "Calling #{req_url}"
      response = conn.get("#{url}/models.json")
      #puts "RESP: #{response}"
      raise "Error getting models: #{response}" unless response.code == 200
      @pools = response.map {|val| Model.new(val, conn)}
    end

  end

  class Model
    attr_accessor :values, :conn
    def initialize(values, conn)
      self.conn = conn
      self.values = values
    end

    def name
      values['name']
    end

    def label=(label)
      values['label'] = label
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

    def associations=(fields)
      values['associations'] = fields
    end

    def id
      values['id']
    end

    def save
      #req_url = "http://#{host}:#{port}#{url}.json?auth_token=#{token}"
      response = if id
        conn.put("#{url}.json", body: {model: values})
      else
        conn.post("#{url}.json", body: {model: values})
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
    attr_accessor :values, :conn
    def initialize(values, conn)
      self.conn = conn
      self.values = values
    end

    def model_id
      values['model_id']
    end

    def identity
      values['identity']
    end

    def pool
      values['pool']
    end

    def url
      values['url'] || "/#{identity}/#{pool}/nodes"
    end

    def url=(url)
      values['url'] = url
    end

    def persistent_id=(id)
      values['persistent_id'] = id
    end

    def associations=(associations)
      values['associations'] = associations
    end

    def persistent_id
      values['persistent_id']
    end

    def save
      response = if persistent_id
        conn.put("#{url}.json", body: {node: values})
      else
        conn.post("#{url}.json", body: {node: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['persistent_id'])
        self.persistent_id = response['persistent_id']
        self.url = response['url']
      end
      values
    end

  end

  def initialize(email, password, port=80, host='localhost')
    self.host = host
    self.port = port
    response = self.class.post("http://#{host}:#{port}/api/v1/tokens", body: {email: email, password: password})
    raise "Error logging in: #{response}" unless response.code == 200
    self.token = response["token"]
  end

  def get(path)
      req_url = "http://#{host}:#{port}#{path}?auth_token=#{token}"
      puts "GET #{req_url}"
      self.class.get(req_url)
  end

  def put(path, args={})
      req_url = "http://#{host}:#{port}#{path}?auth_token=#{token}"
      puts "PUT #{req_url}"
      self.class.put(req_url, args)
  end

  def post(path, args={})
      req_url = "http://#{host}:#{port}#{path}?auth_token=#{token}"
      puts "POST #{req_url}"
      self.class.post(req_url, args)
  end

  def identities
    return @identities if @identities
    response = self.class.get("http://#{host}:#{port}/identities?auth_token=#{token}")
    raise "Error getting identities: #{response}" unless response.code == 200
    @identities = response.map {|val| Identity.new(val, self)}
  end

  def identity(short_name)
    identities.find{|i| i.short_name == short_name}
  end

end
