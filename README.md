Nessus audit vs. show config static file 
========================================


Descrioption
------------
*This utility parses simple rules from the nessus .audit file  for Cisco IO and Cisco Firewall and matches them up with
a static "show run config" file. This utility was made out of necessity, Nessus does not run against static config files,
and requires a live system to audit.

*The tool is not perfect but it makes the "first pass" attempts at pinpointing where to look further, with some guidance.


* ![alt text](./misc/Selection_014.png  "Run with rules")

* ![alt text](./misc/Selection_015.png  "Run with guidance")



The report is broken down by rules: matched, positively violated,  negatively violated or OK
Th ereport is color-coded (ANSI) for ease of digestion. 

* How to read output:

Example output:

	Rule: logging source-interface [Ll]oopback[0-9] should be PRESENT [Possible Negative Violation]

Meaning  "logging source-interface [Ll]oopback[0-9]" rule is negatively violated where is not present and it should be


Example output:
	Rule: snmp-server enable traps should be ABSENT
	 Matched on line  -->snmp-server enable traps tty<-- [Possible Positive Violation] 

Meaning  "snmp-server enable traps" rule is positively violated where it should be absent and it should be absent


The tool makes a reasonable pass at determining the context of the violation and checks:

	Rule: ip directed-broadcast should be ABSENT, in context interface .+

Meaning "ip directed-broadcast" is checked in context of each interface

if verbose output specified ytou also get guidance from CIS matrix on whate to do and where to go next:

Example output: 

__Rule: logging source-interface [Ll]oopback[0-9] should be PRESENT [Possible Negative Violation] __
			Description :"1.2.3.8 Require Binding Logging Service to Loopback Interface - 'Logging source-interface is configured correctly'"
			Info :"Configure logging to include message timestamps."   "ref. https://benchmarks.cisecurity.org/tools2/cisco/CIS_Cisco_IOS_Benchmark_v3.0.1.pdf, page 59."


* Shortcomings:
	- The tool does not yet work with complext conditional statements in the nessus .audit file 
	- The tool cannot populate variables for ytour environment specifieds as {VAR} in the .audit file.
	- You need to check pointed violations manually for completeness as the .audit regexes are sometimes incorrect.
	- it's not  a gem (yet)

* Good news:
	- you can create your own .audit items (as per https://support.tenable.com/support-center/nessus_compliance_reference.pdf )
	and they will i be picked up by the tool.  

* Pre-Requisites:
	- Tested on Ruby 2.0.0
	- Nokogiri gem

* Usage:

`$ ./bin/cisco_audit.rb  --help
	Usage: cisco_audit [options]
    	-v, --verbose
    	-a, --audit FILE
    	-d, --data FILE
    	-h`
`$  ./bin/cisco_audit.rb   -a CIS_v3.0.1_Cisco_IOS_Level_1.audit -d FW-config.conf -v`





