require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'

$auth=Hash.new

def  quest (path, getData=Hash.new, postdata=nil, needAuth=false)   
	uri="http://api.bgm.tv"
	uri=URI("#{uri}#{path}")
	s="onAir"  #or "intouch"
	getData['source']=s
	getData.merge get_auth if needAuth
	uri.query!=nil ? uri.query +="&#{URI.encode_www_form(getData)}" : uri.query = URI.encode_www_form(getData) 
	if postdata==nil
		return   Net::HTTP.get_response(uri).body
	else
		return   Net::HTTP.post_form(uri, postdata).body
	end
end

def authenticate(username="treehole", password="lovemeplease")
	JSON.parse quest("/auth", "POST", {'username'=>username, 'password'=>password})
end

def get_auth
	if $auth != nil
		{'sysusername'=>$auth['username'], 'sysuid'=>$auth['id'], 'auth'=>$auth['auth']}
	else 
		$auth=authenticate
		get_auth
	end
end

#test
path="/collection/1" #Unauthorized
path2="/user/37874/collection?cat=watching" 	
path3="/subject/105875?responseGroup=large"
resJ = JSON.parse quest(path3)
puts resJ['crt']