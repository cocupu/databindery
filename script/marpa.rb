#!/usr/bin/env ruby
#require File.join(File.dirname(__FILE__), '../client/client.rb')
require 'cocupu'
require 'bundler/setup'
Bundler.require(:default)

FILE = File.join(File.dirname(__FILE__), '../spec/fixtures/dechen_rangdrol_archives_database.xls')
#IDENTITY = 'j_coyne'
IDENTITY = 'herp'
POOL = 'marpa'

#conn = Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost')
conn = Cocupu.start('jcoyne@justincoyne.com', 'foobar', 3001, 'localhost')
talk = Cocupu::Model.new({'identity' =>IDENTITY, 'pool'=>POOL, 'name'=>"Talk"})
talk.fields = [
       {"name"=>"File Name", "type"=>"text", "uri"=>"", "code"=>"file_name"},
       {"name"=>"Tibetan Title", "type"=>"text", "uri"=>"", "code"=>"tibetan_title"},
       {"name"=>"English Title", "type"=>"text", "uri"=>"", "code"=>"english_title"},
       {"name"=>"Author", "type"=>"text", "uri"=>"", "code"=>"author"},
       {"name"=>"Date", "type"=>"text", "uri"=>"", "code"=>"date"},
       {"name"=>"Time", "type"=>"text", "uri"=>"", "code"=>"time"},
       {"name"=>"Size", "type"=>"text", "uri"=>"", "code"=>"size"},
       {"name"=>"Location", "type"=>"text", "uri"=>"", "code"=>"location"},
       {"name"=>"Access", "type"=>"text", "uri"=>"", "code"=>"access"},
       {"name"=>"Originals", "type"=>"text", "uri"=>"", "code"=>"originals"},
       {"name"=>"Master", "type"=>"text", "uri"=>"", "code"=>"master"},
       {"name"=>"Notes", "type"=>"text", "uri"=>"", "code"=>"notes"},
       {"name"=>"Notes (cont)", "type"=>"text", "uri"=>"", "code"=>"notes2"}
       ]
talk.label = 'file_name'
talk.save

recording = Cocupu::Model.new({'identity' =>IDENTITY, 'pool'=>POOL, 'name'=>"Recording"})
recording.fields = [
       {"name"=>"File Name", "type"=>"text", "uri"=>"", "code"=>"file_name"},
       {"name"=>"Time", "type"=>"text", "uri"=>"", "code"=>"time"},
       {"name"=>"Size", "type"=>"text", "uri"=>"", "code"=>"size"},
       {"name"=>"Notes", "type"=>"text", "uri"=>"", "code"=>"notes"},
       {"name"=>"Notes (cont)", "type"=>"text", "uri"=>"", "code"=>"notes2"}
       ]
recording.associations = [ {"type"=>"Has One","name"=>"talk","references"=>talk.id}]
recording.label = 'file_name'
recording.save

def load_sheet(talk, recording)
  spreadsheet = Roo::Excel.new(FILE)
  worksheet = spreadsheet.sheets.first

  last_talk = nil
  (spreadsheet.first_row(worksheet) + 2).upto(spreadsheet.last_row(worksheet)) do |row_idx|
    node = nil
    if spreadsheet.cell(row_idx, 2, worksheet)
      ## A Talk
      node = Cocupu::Node.new({'identity'=>IDENTITY, 'pool'=>POOL, 'model_id' => talk.id, 'data' => talk_data(spreadsheet, row_idx, worksheet)})
      node.save
      last_talk = node.persistent_id
    else
      ## Recording.
      node = Cocupu::Node.new({'identity'=>IDENTITY, 'pool'=>POOL, 'model_id' => recording.id, 'data' => recording_data(spreadsheet, row_idx, worksheet)})
      node.associations = {"talk" =>[last_talk]}
      node.save
    end
  end
end

def talk_data (spreadsheet, row_idx, worksheet)
  fields = ["file_name", "tibetan_title", "english_title", "author", "date", "time", "size", "location", "access", "originals", "master", "notes", "notes2"]
  data = {}
  fields.each_with_index do |field, idx|
    data[field] = spreadsheet.cell(row_idx, idx + 1, worksheet)
  end
  data
end


def recording_data (spreadsheet, row_idx, worksheet)
  fields = ["file_name", nil, nil, nil, nil, "time", "size", nil, nil, nil, nil, "notes", "notes2"]
  data = {}
  fields.each_with_index do |field, idx|
    data[field] = spreadsheet.cell(row_idx, idx + 1, worksheet) if field
  end
  data
end

load_sheet(talk, recording)
