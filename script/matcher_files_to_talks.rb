#!/usr/bin/env ruby
require "cocupu"

email = "matt@cocupu.com"
password = "cooties"

def process_file_entities(file_entities)
  file_entities.each do |fe|
    file_name = fe.data["file_name"]
    if file_name.include?(".mp3")
      anticipated_talk_title = file_name.gsub("_", '/').gsub(".mp3", "").gsub("5c-talk","")
      matching_talks = Cocupu::Node.find("birgitscott", "ktgrtp", "teaching_talk_title" => anticipated_talk_title)
      if matching_talks.count > 1
        puts "[skip] Skipping #{anticipated_talk_title} because there are too many matches (#{matching_talks.count} matches)"
      elsif matching_talks.count == 1
        talk = matching_talks.first
        talk.associations["files"] ||= []
        if talk.associations["files"].include?(fe.persistent_id)
          puts "[skip] #{talk.data["talk_title"]}"
          puts "         already includes"
          puts "         #{file_name}"
        else
          talk.associations["files"] << fe.persistent_id
          #result = talk.save
          puts "[assign] #{talk.data["talk_title"]} now includes"
          puts "         now includes"
          puts "         #{file_name}"
          #puts result.inspect
        end
      else
        puts "[skip] No matches found for #{anticipated_talk_title}"
      end
    end
  end
end


@conn = Cocupu.start(email, password, 80, "bindery.cocupu.com")
names = ["SKK8.4.dus.'khor.sbyor.drug-berkeley-1994","chos.dbyings.bstod.pa-kathmandu-1997-rfu","mi.la.mchog.bzhi.dang.mchog.gyur.bcu.gcig", "dbus.mtha'.rnam.'byed.zhi.gnas.lhag.mthong-montreal-1991", "mi.la.bslu.bslu.'dra.bcu.gnyis-ludwigshorst-1994-ams-tg", "mi.la.mchog.bzhi.dang.mchog.gyur.bcu.gcig-delhi-1992-kbr", "mi.la.rnal.'byor.bde.ba.bcu.gnyis-ludwigshorst-1994-ams"]
names.each do |name|
  file_entities = Cocupu::Node.find("birgitscott", "ktgrtp", "model_name" => "File Entity", "file_name"=>name)
  puts "Found #{file_entities.count} File Entities."
  process_file_entities(file_entities)
end


