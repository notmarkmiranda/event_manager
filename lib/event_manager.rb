require 'csv'
require 'sunlight/congress'
require 'erb'
require 'pry'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phonenumber)
  validate_phone_number(phonenumber.chars.select { |digit| digit if digit =~ /[0-9]/ }.join)
end

def validate_phone_number(phonenumber)
  if (phonenumber.length == 11 && phonenumber[0] == "1")
    phonenumber = phonenumber[-10..-1]
  elsif phonenumber.length == 10 && phonenumber[0] != "1"
    phonenumber
  else
    phonenumber = "0000000000"
  end
  format_phone_number(phonenumber)
end

def format_phone_number(phonenumber)
  phonenumber = phonenumber.insert(3, "-").insert(7, "-")
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "Event Manager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phonenumber = clean_phone_number(row[:homephone])
  regdate = Date.strptime(row[:regdate], "%m/%d/%y %H:%M")
  # THIS IS WHERE I STOPPED

  legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letters(id, form_letter)
end
