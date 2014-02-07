#!/usr/bin/env ruby



require 'optparse'
require 'term/ansicolor'
include Term::ANSIColor


require File.join(File.dirname(__FILE__), '..', 'lib/cisco/cisco')

# parse arguments
dataload={}
file = __FILE__

ARGV.options do |opts|
  opts = OptionParser.new
  opts.on("-v", "--verbose")            { |val| dataload[:verbose] = true}
  opts.on("-a", "--audit FILE", String) { |val| dataload[:audit_file] = val }
  opts.on("-d", "--data FILE", String)  { |val| dataload[:data_file] = val }
  opts.on_tail("-h") {
    puts "Usage: #{__FILE__} -a <nessus_auditfile> -d <showconfig_datafile>"
  }
  opts.parse!
end



if (not dataload.has_key?(:data_file) ) and (not dataload.has_key?(:audit_file))
  exit 5
end

#audit_file="./CIS_v3.0.1_Cisco_IOS_Level_1.audit"
#audit_file="./CIS_v3.0.1_Cisco_Firewall_Level_1.audit"

#data_file="./VPN_Router_2811_primary.log"
#data_file="./Internet_FW_ASA5540.log"

ap=AuditProcessor.new

ap.load_rules(dataload[:audit_file])
ap.load_data(dataload[:data_file])

# Cross-reference audit rules  to  data fro show [running] config
ap.match_to_rules



puts red( bold( "*** CISCO CIS COMPLIANCE REPORT (static file) ***" ) )
ap.dump_rules(dataload[:verbose])

###############

#simple_items_collection.each do |si|
#  puts "Description: #{si.description}" if not si.description.empty?
#  puts "\tInfo: #{si.info}" if not si.info.empty?
#  puts "\tItem: #{si.item}" if not si.item.empty?
#  puts "\tContext: #{si.context}" if not  si.context.empty?
#  puts "\tRegex: #{si.regex}" if not si.regex.empty?
#  puts "\tRequired: #{si.required}" if not si.required
#  puts "\tType: #{si.type}"
#  puts "\n" * 2
#end









