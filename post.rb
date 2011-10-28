#!/usr/bin/env ruby

# Xcode auto-versioning script for Subversion by Axel Andersson
# Updated for git by Marcus S. Zarra and Matt Long
# Converted to ruby by Abizer Nasir
# Appends the git sha to the version number set in Xcode.
# see http://www.stompy.org/2008/08/14/xcode-and-git-another-build-script/ for more details

# These are the common places where git is installed. 
# Change this if your path isn't here
common_git_paths = %w[/usr/local/bin/git /usr/local/git/bin/git /opt/local/bin/git]
git_path = ""

common_git_paths.each do |p|
  if File.exist?(p)
    git_path = p
    break
  end
end

if git_path == ""
  puts "Path to git not found"
  exit
end

command_line = git_path + " rev-parse --short HEAD"
sha = `#{command_line}`.chomp
puts sha

info_file = ENV['BUILT_PRODUCTS_DIR'] + "/" + ENV['INFOPLIST_PATH']

f = File.open(info_file, "r").read
re = /([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>)(.*?)(<\/string>)/
f =~ re

# Get the version info from the source Info.plist file
# If the script has already been run we need to remove the git sha
# from the bundle's Info.plist.
open = $1
orig_version = $2
close = $3

# If the git hash has not already been injected into the Info.plist, this will set version to nil
version = $2.sub!(/\s*git sha [\w]+/, '')
if (!version)
  version = orig_version
end

# Inject the git hash into the bundle's Info.plist
sub = "#{open}#{version}git sha #{sha}#{close}"
puts sub
f.gsub!(re, sub)
File.open(info_file, "w") { |file| file.write(f) }