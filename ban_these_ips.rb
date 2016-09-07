#!/usr/bin/env ruby

#
#IP SECTION
#

### PART 1 grep /var/log/secure for authentication failure and puts the ip addresses into ip
names = File.open('/var/log/secure', 'r') do |f|
  f.grep(/authentication failure/)
end
fname = "failed"
somefile = File.open(fname, 'w')
somefile.puts names
somefile.close

#opens the file failed and strips the lines of everything before rhost 
fname = "temp_file_failed_2"
somefile = File.open(fname, 'w')
File.open("failed").each do |line|
    if line[/rhost/]
        somefile.puts line.split("rhost=")[-1].strip
    end
  end
somefile.close

#strips the edited lines everything except IP addresses
fname2 = "allip"
somefile2 = File.open(fname2, 'w')
File.open('temp_file_failed_2') do |infile|
  while line = infile.gets        
    line_split = line.split(" ")  
    somefile2.puts line_split[0]            
  end
end
somefile2.close

#remove entries that are not just ip's. Removes entries with .net
system("ruby -ne 'print if not /net/' allip > ipnotnet")
system("ruby -ne 'print if not /com/' ipnotnet > ipnotcom")
system("ruby -ne 'print if not /at/' ipnotcom > ipnotat")
system("ruby -ne 'print if not /cn/' ipnotat > ipnotcn")
system("ruby -ne 'print if not /tw/' ipnotcn > ipnottw")
system("ruby -ne 'print if not /cz/' ipnottw > ip")

### PART 2 grep /var/log/secure for invalid user and puts them in failed_user
users = File.open('/var/log/secure', 'r') do |f|
  f.grep(/Invalid user/)
end
fname = "failed_user"
somefile = File.open(fname, 'w')
somefile.puts users
somefile.close

#opens the file failed_user and strips the lines of everything before from and appends to ip file
fname = "ip"
somefile = File.open(fname, 'a')
File.open("failed_user").each do |line|
    if line[/Invalid/]
        somefile.puts line.split("from ")[-1].strip
    end
  end
somefile.close

### PART 3 grep /var/log/secure for identification string and puts them in failed_id
users = File.open('/var/log/secure', 'r') do |f|
  f.grep(/identification string/)
end
fname = "failed_ip"
somefile = File.open(fname, 'w')
somefile.puts users
somefile.close

#opens the file failed_id and strips the lines of everything before from and appends to ip file
fname = "ip"
somefile = File.open(fname, 'a')
File.open("failed_ip").each do |line|
    if line[/string/]
        somefile.puts line.split("from ")[-1].strip
    end
  end
somefile.close

### PART 4 grep /var/log/secure for Received disconnect string and puts them in failed_disconnect
users = File.open('/var/log/secure', 'r') do |f|
  f.grep(/Received disconnect/)
end
fname = "failed_disconnect"
somefile = File.open(fname, 'w')
somefile.puts users
somefile.close

#opens the file temp disconnect and strips the lines of everything before from 
fname = "temp_disconnect"
somefile = File.open(fname, 'w')
File.open("failed_disconnect").each do |line|
    if line[/disconnect/]
        somefile.puts line.split("from ")[-1].strip
    end
  end
somefile.close

#strips the edited lines everything except IP addresses and appends to ip
fname2 = "ip"
somefile2 = File.open(fname2, 'a')
File.open('temp_disconnect') do |infile|
  while line = infile.gets        
    line_split = line.split(":")  
    somefile2.puts line_split[0]            
  end
end
somefile2.close

### PART 5 grep /var/log/secure reverse mapping and puts them in failed_reverse
users = File.open('/var/log/secure', 'r') do |f|
  f.grep(/reverse mapping/)
end
fname = "failed_reverse"
somefile = File.open(fname, 'w')
somefile.puts users
somefile.close

#opens the file temp reverse and strips the lines of everything before from 
fname = "temp_reverse"
somefile = File.open(fname, 'w')
File.open("failed_reverse").each do |line|
    if line[/reverse/]
        somefile.puts line.split(" [")[-1].strip
    end
  end
somefile.close

#strips the edited lines everything except IP addresses and appends to ip
fname2 = "ip"
somefile2 = File.open(fname2, 'a')
File.open('temp_reverse') do |infile|
  while line = infile.gets        
    line_split = line.split("]")  
    somefile2.puts line_split[0]            
  end
end
somefile2.close

### PART 6 grep /var/log/secure reverse Bad protocol and puts them in failed_reverse
users = File.open('/var/log/secure', 'r') do |f|
  f.grep(/Bad protocol/)
end
fname = "failed_protocol"
somefile = File.open(fname, 'w')
somefile.puts users
somefile.close

#opens the file failed_protocol and strips the lines of everything before from and appends to ip file
fname = "failed_protocol_temp"
somefile = File.open(fname, 'w')
File.open("failed_protocol").each do |line|
    if line[/protocol/]
        somefile.puts line.split("from ")[-1].strip
    end
  end
somefile.close

#strips the edited lines everything except IP addresses
if  (system"grep 'port' failed_protocol_temp > /dev/null")
   fname = "ip"
   somefile = File.open(fname, 'a')
   File.open('failed_protocol_temp') do |infile|
     while line = infile.gets        
       line_split = line.split(" ")  
       somefile.puts line_split[0]
      end
    end
    somefile.close
  else
    fname2 = "ip"
    somefile2 = File.open(fname2, 'a')
    File.open('failed_protocol_temp') do |infile|
      somefile2.puts
    end
    somefile2.close
  end

#Open file and sort it and remove duplicate entries
my_array = IO.readlines('ip').map(&:strip).uniq
fname = "ips_sorted"
somefile = File.open(fname, 'w')
somefile.puts my_array.sort_by(&:to_i)
somefile.close

#
#RULES SECTION
#

#Get all public zone firewall bans and write them to rules file
system("firewall-cmd --zone=public --list-rich-rules > rules")

#opens the file rules and strips the lines of everything before source address="
fname = "rules2"
somefile = File.open(fname, 'w')
File.open("rules").each do |line|
    if line[/source address/]
        somefile.puts line.split("source address=\"")[-1].strip
    end
  end
somefile.close

#strips the edited lines everything except IP addresses
fname2 = "rules3"
somefile2 = File.open(fname2, 'w')
File.open('rules2') do |infile|
  while line = infile.gets        
    line_split = line.split("\"")  
    somefile2.puts line_split[0]            
  end
end
somefile2.close

#Open file and sort it and remove duplicate entries
my_array = IO.readlines('rules3').map(&:strip).uniq
fname = "rules_sorted"
somefile = File.open(fname, 'w')
somefile.puts my_array.sort_by(&:to_i)
somefile.close

#
#Compute what IPs to ban section
#

#remove any IPs from the exclusion list from the ips_sorted list
my_array = IO.readlines('ips_sorted').map(&:strip)
my_array2 = IO.readlines('ip_exclude').map(&:strip)
my_array3 = my_array - my_array2
fname = "ips_out"
somefile = File.open(fname, 'w')
somefile.puts my_array3
somefile.close

#remove any rules from the exclusion list from the rules_sorted list
my_array = IO.readlines('rules_sorted').map(&:strip)
my_array2 = IO.readlines('rules_exclude').map(&:strip)
my_array3 = my_array - my_array2
fname = "rules_out"
somefile = File.open(fname, 'w')
somefile.puts my_array3
somefile.close

#tells you what ips need to be banned

my_array = IO.readlines('ips_out').map(&:strip)
my_array2 = IO.readlines('rules_out').map(&:strip)
my_array3 = my_array - my_array2
fname = "ban_these_ips"
somefile = File.open(fname, 'w')
somefile.puts my_array3
somefile.close


#append the IPS banned to a file to review later
fname2 = "ips_auto_banned"
somefile = File.open(fname2, 'a')
somefile.puts my_array3
somefile.close

#strips the carriage returns and loads into array
ban_array = IO.readlines('ban_these_ips').map(&:chomp).map(&:strip)


#ban the ips
if ban_array.length !=0
  while ban_array.length !=0
  system("firewall-cmd --permanent --zone=\"public\" --add-rich-rule='rule family=\"ipv4\" source address=\"#{ban_array[0]}\" reject' > /dev/null")
  ban_array.shift
  end
  system("firewall-cmd --reload")
else
end

#email administrator

if my_array3.length !=0
system("cp email_header email_comp")
fname = "email_comp"
somefile = File.open(fname, 'a')
somefile.puts my_array3
somefile.close
system("sendmail sean.oshea@outlook.com <<EOF
$(cat email_comp)
EOF")
else
end

#file clean up
system("rm -f ips_out rules_out rules_sorted ips_sorted rules3 rules2 ip temp_file_failed_2 failed rules failed_user failed_ip failed_disconnect temp_disconnect failed_reverse temp_reverse failed_protocol email_comp failed_protocol_temp ipnotat ipnotcom ipnotnet ban_these_ips allip ipnotcn ipnottw")
