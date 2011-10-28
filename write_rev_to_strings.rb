#!/usr/bin/env ruby
require 'rubygems' 
require 'nokogiri'

common_git_paths = "which git"
git_path = `#{common_git_paths}`.chomp
file_name = 'res/values/strings.xml'

abort('File not found') unless File.exists?(file_name)
abort('Path not found') if (git_path.empty?)

command_line = git_path + " rev-parse --short HEAD"
sha = 'rev. ' + `#{command_line}`.chomp + DateTime.now.strftime('%d/%m/%Y %h:%m:%s')

doc = Nokogiri::XML(File.open(file_name))
revisions  = doc.xpath("//string[@name='revision']")

if revisions.length > 0
  revision = revisions[0];
else
  revision = Nokogiri::XML::Node.new('string',doc)
  revision['name'] ="revision"
  doc.children.first.children.before(revision)
end

revision.content = sha
File.open(file_name, 'w') {|f| f.puts doc.to_xml }