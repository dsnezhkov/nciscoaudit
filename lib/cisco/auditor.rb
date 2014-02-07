
require 'nokogiri'
require 'term/ansicolor'
include Term::ANSIColor

require_relative 'aitem'
require_relative 'ditem'

class AuditProcessor


  attr_accessor :data_rows, :xml, :simple_items_collection

  def initialize
    @data_rows=Array.new
    @xml=String.new
    @simple_items_collection=Array.new
  end

  def load_rules(audit_file)
    # Delimited Tags that will be converted to XML
    tags=%w[info type description item context regex required]

    count=0

    begin
      File.open(audit_file, "r") do |f|
        f.each_line do |line|
          next if line =~ /^\s*#/

          # converting  to proper XML tag
          line.gsub!(/(check_type)\s*:\s*/, '\1 type=')
          line.gsub!(/(condition) type\s*:\s*/, '\1 type=')
          line.gsub!(/(report) type\s+:\s+/, '\1 type=')


          # Creating proper XML tag
          tags.each do |tag|
            line.gsub!(/(\s+)#{tag}\s+:(.*)/, "\\1<#{tag}> \\2 </#{tag}>")
          end

          #puts "#{count} : #{line}"

          @xml << line
          count += 1
        end
      end
    rescue Exception => e
      puts $stderr, 'Error processing the audit file : ', e.message
      raise  ScriptError,  'Please make sure the file is found and can be read'
    end

    parse_rules

  end


  def load_data(data_file)

    begin

      File.open(data_file, "r") do |f|

        f.each_line do |line|
          next if line =~ /^\s*$/


          context=line.chomp!

          mt = line.match(/^\s(\w+)/)
          if mt.nil?
            #puts "Context #{context}"
            @data_rows.push(DItem.new(line, context))
          else
            context=mt.captures
            #puts "Sub-Context: #{context[0]}"
            @data_rows.push(DItem.new(line, context[0]))
          end
        end
      end

    rescue Exception => e
      puts $stderr, 'Error processing the data file : ', e.message
      raise  ScriptError,  'Please make sure the file is found and can be read'
    end

  end

  def parse_rules
    audit_rules_parse = Nokogiri::XML(@xml)


    simple_items=audit_rules_parse.xpath("/check_type/item")
    simple_items.each do |si|
      audit_item=AItem.new
      audit_item.type=si.xpath("./type").inner_text.strip!
      audit_item.description=si.xpath("./description").inner_text.strip!
      audit_item.info=si.xpath("./info").inner_text.strip!
      audit_item.item=si.xpath("./item").inner_text.strip!
      audit_item.context=si.xpath("./context").inner_text.strip!
      audit_item.required=si.xpath("./required").inner_text
      audit_item.regex=si.xpath("./regex").inner_text.strip!
      audit_item.detected = String.new("")

      @simple_items_collection << audit_item
    end

  end

  def match_to_rules
    @simple_items_collection.each do |si|
      #puts "Processing rule:  #{si.item}"

      @data_rows.each do |dr|
        match=false

        out=""
        out << "\tMatching  (#{dr.line})"
        out << " against item (#{si.item})"

        if (not si.context.nil?) and (not si.context.empty?)
          si.context=si.context.gsub(/"/, '')
        end

        if (not si.regex.nil?) and (not si.regex.empty?)
          out << " and with REGEX "
          out << "(#{si.regex})"

          si.regex=si.regex.gsub(/"/, '')
          if dr.line =~ /#{si.regex}/
            if (not si.context.nil?) and (not si.context.empty?)
              si.context=si.context.gsub(/"/, '')
              if dr.context =~ /#{si.context}/
                match=true
                si.detected = dr.line.to_s
              end
            else
              match=true
              si.detected = dr.line.to_s
            end
          end

        else

          si.item=si.item.gsub(/"/, '')
          if dr.line =~ /#{si.item}/
            if (not si.context.nil?) and (not si.context.empty?)
              si.context=si.context.gsub(/"/, '')
              if dr.context =~ /#{si.context}/
                match=true
                si.detected = dr.line.to_s
              end
            else
              match=true
              si.detected = dr.line.to_s
            end
          end
        end

        #puts out if match

      end

    end
  end

  def dump_rules(verbose=false)
    @simple_items_collection.each do |si|
      out=""
      out << "\n\tRule: "
      out << green { "#{si.item}" }
      out << " should be "
      out << "#{(si.type.include? "NOT") ? blue { "ABSENT" } : cyan { "PRESENT" } }"
      if (not si.context.nil?) and (not si.context.to_s.empty?)
        out << ", in context "
        out << yellow { "#{si.context}" }
      end

      if (not si.regex.nil?) and (not si.regex.to_s.empty?)
        out << " , and searchable via regex "
        out << magenta { "#{si.regex}" }
      end

      if not si.detected.to_s.empty?
        out << blue { "\n\t\t Matched on line  -->#{si.detected}<--" }
      end

      #out << "\n\t\t\tDetected: #{si.detected.inspect}, empty?, #{si.detected.empty?}, Type: #{si.type.inspect}"

      if si.detected.to_s.empty? and si.type.to_s =~ /^CONFIG_CHECK$/
        out << red {" [Possible Negative Violation] "}
        if verbose
          out << white { "\n\t\t\tDescription :" }
          out << si.description
          out << "\n\t\t\tInfo :"
          out << white { si.info }
        end
      end

      if (not si.detected.to_s.empty?) and  si.type.to_s =~ /^CONFIG_CHECK_NOT$/
        out << red  { bold {" [Possible Positive Violation] "} }
        if verbose
          out << white { "\n\t\t\tDescription :" }
          out << si.description
          out << "\n\t\t\tInfo :"
          out << white { si.info }
        end
      end

      puts out
    end
  end




end
