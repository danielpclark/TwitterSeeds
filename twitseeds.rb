# Twitter Seeds
# Little goodness from your feed

require 'rubygems'
require 'mechanize'
require 'highline/import'
require 'mightystring'

puts "#{HighLine::GREEN}Twitter Seeds . . .#{HighLine::CLEAR}"
puts "#{HighLine::RED}Be advised. This script logs in each update.#{HighLine::CLEAR}"
puts "#{HighLine::YELLOW}Twitter is okay with that.  Are you?#{HighLine::CLEAR}"

USERNAME = ask("Twitter Username: ")
PASSWORD = ask("Twitter Password: "){ |q| q.echo = '*' }

def getFeed
	instance = Mechanize.new

	page =  begin 
			instance.get 'https://m.twitter.com/session/new'
		rescue
			yield
		end

	return page.form_with(:action => 'https://mobile.twitter.com/session') do |session|
		session.username = USERNAME
		session.password = PASSWORD
	end.submit
end

module MightyString
	module HTML
		def self.html_to_text_codes
			{"twitter_external_link" => HighLine::MAGENTA,
			"a>" => HighLine::CLEAR }
		end
		
		def self.math_by_space
			false
		end
	end
end

def markHash(instr)
	MightyString::HTML.strip_html(instr).split.map do |x|
		if !!x[0]['#']
			HighLine::RED + x + HighLine::CLEAR
		elsif !!x[0]['@']
			HighLine::YELLOW + x + HighLine::CLEAR
		else
			x
		end
	end.join(' ')
end

def diff(x,y)
	o = x
	x = x.reject{|a| if y.include?(a); a end }
	y = y.reject{|a| if o.include?(a); a end }
	x | y
end

currentFeed, oldFeed = [], []

while true
	Nokogiri::HTML(getFeed.body, "UTF-8").css('table.tweet').each do |tweet|
		currentFeed << " #{ HighLine::BLUE + tweet.css("span.username").text.strip() + HighLine::CLEAR }  #{ markHash( tweet.css('div.tweet-text').inner_html ) }"
	end
	currentFeed = currentFeed.reverse
	puts diff(currentFeed, oldFeed)
	oldFeed = currentFeed
	currentFeed = []
	sleep 180
end
