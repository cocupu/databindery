#!/usr/bin/env ruby

require 'httparty'

HOST = "localhost:8080"

class Bindery
  include HTTParty

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

    # def url
    #   values["url"]
    # end

  end

  class Model

  end

  def initialize(email, password)
    response = self.class.post("http://#{HOST}/api/v1/tokens", body: {email: email, password: password})
    raise "Error logging in: #{response}" unless response.code == 200
    @token = response["token"]
  end

  def identities
    return @identities if @identities
    response = self.class.get("http://#{HOST}/identities?auth_token=#{@token}")
    raise "Error getting identities: #{response}" unless response.code == 200
    @identities = response.map {|val| Identity.new(val, @token)}
  end

  def identity(short_name)
    identities.find{|i| i.short_name == short_name}
  end

end

b = Bindery.new('jcoyne@justincoyne.com', 'foobar')
puts "ident " + b.identity('herp').pool('bergen_library').inspect





