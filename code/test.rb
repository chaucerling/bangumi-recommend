#!/usr/bin/ruby
require 'rubygems'

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
#require 'jcode'
#$KCODE='utf8' 

uri = URI('http://api.bgm.tv/subject/95225?responseGroup=large')
uri2= URI('http://bgm.tv/subject/95225')
#params = [ 10, :page => 3 ]
#uri.query = URI.encode_www_form(params)

#by html
res = Net::HTTP.get_response(uri)
resJson = JSON.parse res.body
staff = resJson['staff']
# print staff
staff.each do |i|
	puts "#{i['name']}  #{i['jobs']}"
end


#by api
Net::HTTP.start 'bgm.tv' do |http|
	request = Net::HTTP::Get.new uri2
	res = http.request request 
	doc = Nokogiri::HTML(res.body)
	items= doc.css('.subject_tag_section>.inner')
	tags= doc.css('.subject_tag_section>.inner >a')
	amount= doc.css('.subject_tag_section>.inner >small')
	n = tags.size
	tagAry = Array.new
	for i in 0..n-1
		tagAry.push([ tags[i].content , amount[i].content.delete("()") ])
	end
	# print tags
	tagAry.each do |i|
		puts "#{i[0]}  #{i[1]}"
	end
end
