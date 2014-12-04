#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
#require 'jcode'
#$KCODE='utf8' 
require 'set'
require 'optparse'
require 'chinese_convt'
require 'insensitive_hash'

#modify error that the  dom note  is nil  when getting its content
def get_content(e)
	if e == nil
		return "   "
	else return e.content
	end
end


def get_tags (http,id)
	subject_res = http.request_get("/subject/#{id}") 
	doc = Nokogiri::HTML(subject_res.body)
	tag= doc.css('.subject_tag_section>.inner >a')
	amount= doc.css('.subject_tag_section>.inner >small')
	n = tag.size
	tagAry = Array.new
	for i in 0..n-1
		tagAry << {'name'=>tag[i].content , 'amount'=>amount[i].content.delete("()").to_i}  
	end
	return tagAry
end


def get_staff (http,id)
	subject_res = http.request_get("/subject/#{id}/persons")
	doc = Nokogiri::HTML(subject_res.body)
	items= doc.css('#columnInSubjectA>.light_odd>div:last')
	staff=Array.new
	items.each do |i|
		names=i.at_css('h2>a').content.split('  / ')<<""
		staff << {'id'=>i.at_css('h2>a')['href'].delete('person/ ').to_i , 'name'=>names[0] .rstrip, 'name_cn'=>names[1]}
	end
	return staff
end

def get_crt(http, id)
	subject_res = http.request_get("/subject/#{id}/characters")
	doc = Nokogiri::HTML(subject_res.body)
	items= doc.css('#columnInSubjectA>.light_odd>div:last')
	crt=Array.new
	items.each do |i|
		actorinfo=i.css('.actorBadge')
		actors=Array.new
		if actorinfo 
			actorinfo.each  do |j|
				actors << {'id'=>j.at_css('a')['href'].delete('person/ ').to_i , 'name'=>j.at_css('p>a').content , 'name_cn'=>j.at_css('p>small').content}
			end
		end
		crt << {'id'=>i.at_css('h2>a')['href'].delete('character/ ').to_i , 'name'=>i.at_css('h2>a').content , 'name_cn'=>get_content(i.at_css('h2>.tip'))[3..-1] , 'actors'=>actors}
	end
	return crt
end

def get_collect (http,uid)
	state="collect"
	category="anime" 
	progress = true
	base_url = "/#{category}/list/#{uid}/#{state}"
	collect=Array.new
	$stderr.puts base_url if progress
	for i in 1..Float::INFINITY
		url = "#{base_url}?page=#{i}"
		$stderr.print "fetching page ##{i}... " if progress
		collect_res = http.request_get(url)
		doc = Nokogiri::HTML(collect_res.body)
		items = doc.css('#browserItemList>li')
		items.each do |item|
			sid =  item.at_css('a')['href'].delete('subject/ ').to_i
			starinfo = item.at_css('.starsinfo')
			rank = if starinfo
				starinfo[:class].split[0][6..-1].to_i
			else 0
			end
			collect[sid]=rank
		end
		$stderr.puts items.size if progress
		break if items.size < 24
	end
	return collect
end

def get_subject_info(http,sid)
	tagsinfo=get_tags(http,sid)
	staffinfo=get_staff(http,sid)
	castinfo=get_crt(http,sid)
	return {'id'=>sid , 'tag'=>tagsinfo.value ,  'staff'=>staffinfo , 'crt'=>castinfo.value}
end


sid = 95225
uid= "treehole"

#test
Net::HTTP.start 'bgm.tv' do |http|
	t= Time.now
	puts t
	puts  get_subject_info(http,11834)
	puts Time.now-t
	#get_collect(http,uid)
end







