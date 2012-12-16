# Twitter Seeds
# Little goodness from your feed
# The MIT License


require 'rubygems'
require 'mechanize'
require 'highline/import'
require 'mightystring'

puts "#{HighLine::GREEN}Twitter Seeds . . .#{HighLine::CLEAR}"
puts "#{HighLine::RED}Be advised. This script logs in each update.#{HighLine::CLEAR}"
puts "#{HighLine::YELLOW}Twitter api is okay with that.  Are you?#{HighLine::CLEAR}"

USERNAME = ask("Twitter Username: ")
PASSWORD = ask("Twitter Password: "){ |q| q.echo = '' }

def getFeed
	instance = Mechanize.new

	page =  begin 
			instance.get 'https://m.twitter.com/session/new'
		rescue => e
			e
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

currentFeed, history = [], []

while true
	Nokogiri::HTML(getFeed.body, "UTF-8").css('table.tweet').each do |tweet|
		currentFeed << " #{ HighLine::BLUE + tweet.css("span.username").text.strip() + HighLine::CLEAR }  #{ markHash( tweet.css('div.tweet-text').inner_html ) }"
	end
	currentFeed = currentFeed.reverse
	currentFeed.each do |item|
		if not history.include?(item)
			history << item
			if history.length > 30
				history = history[1..-1]
			end
			puts item
		end
	end
	currentFeed = []
	sleep 180
end
