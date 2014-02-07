#!/usr/bin/env ruby



require 'term/ansicolor'
include Term::ANSIColor


require_relative 'cisco/cisco'




#audit_file="./CIS_v3.0.1_Cisco_IOS_Level_1.audit"
audit_file="./CIS_v3.0.1_Cisco_Firewall_Level_1.audit"

#data_file="./VPN_Router_2811_primary.log"
data_file="./Internet_FW_ASA5540.log"

ap=AuditProcessor.new

ap.load_rules(audit_file)
ap.load_data(data_file)
ap.match_to_rules

puts red( bold( "*** CISCO CIS COMPLIANCE REPORT (static file) ***" ) )
ap.dump_rules

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









