namespace :crawling do
	require 'rufus-scheduler'
	require 'uri'
	require 'net/http'
desc "get_cyclub"
task :get_cyclub => :environment do
	  puts "go!"
		  url = URI("http://club.cyworld.com/club/board/general/ListNormal.asp?cpage=1&club_id=52606748&board_no=8&board_type=1&list_type=2&show_type=1&headtag_seq=&search_type=&search_keyword=&search_block=1")
		  puts"going"

		  http = Net::HTTP.new(url.host, url.port)
		  request = Net::HTTP::Get.new(url)
		  request["cache-control"] = 'no-cache'
		  request["postman-token"] = '31ad059c-8460-8dcd-c003-85e7d2c45735'
		    @response = http.request(request)
		    @result = Nokogiri::HTML(@response.read_body.force_encoding('euc-kr').encode('utf-8'))
		    @numbers = @result.css('tbody tr td.col_num')
		    @titles = @result.css('tbody tr td.col_title a')
		    @numbers.each_with_index do |value, index|
		      if value.inner_text.to_i > 0
			@index = index
			break
		      end
		    end
		   puts "index: @index"
		    @first_number = @numbers[@index].inner_text.to_i
		    @first_title = @titles[@index].inner_text
		    latest_cyworld = Post.last
		   puts "check new post"
		    if @first_number != latest_cyworld.post_num
		      while @numbers[@index].inner_text.to_i > latest_cyworld.post_num  do
			@title = @titles[@index].inner_text
			href = @titles[@index][ 'onclick']
			post_num = /(?<=item_seq=)[0-9]{0,}/.match(href).to_s
			@real_link = 'http://m.club.cyworld.com/52606748/Article/8/View/' + post_num
			url = "https://api.telegram.org/bot323491341:AAEbBPY4KtdtPdlLL9mGdK3qH3Wd10xdFfM/sendMessage?chat_id=-215545010&text= New notice: #{@title}, Link: #{@real_link}"

			enc_url = URI.escape(url)

			url = URI(enc_url)

			Rails.logger.info "url: #{url}"

		       http = Net::HTTP.new(url.host, url.port)
		       http.use_ssl = true
		       http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		       request = Net::HTTP::Get.new(url)
		       request["cache-control"] = 'no-cache'
		       request["postman-token"] = '687a1a5e-1aa4-2def-c140-c2dc6596d046'

		       response = http.request(request)
			@index += 1
			puts @index
		      end
		      Post.create(post_num: @first_number, title: @first_title)
		    end
puts "end"
end
end
