# http://www.meijijingugaien.jp/sports/tennis-club/
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'business_time'
require 'pry'
require 'pp'

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end



available_dates = []
i = 1
start = Date.new(2018,12,1)
date = start
loop do
  break if date.month != start.month
  if true || date.workday?
    y = date.strftime('%Y')
    m = date.strftime('%m')
    d = date.strftime('%d')
    url = 'http://www.meijijingugaien.jp/sports/futsal/reserve.php?y=' + y + '&m=' + m + '&d=' + d
    p url
    begin
      doc = Nokogiri::HTML(open(url))

      tables = doc.css('.table01')
      tables.each do |table|
        court = table.css('tbody > tr > td')[1].text
        heads = table.css('thead > tr > th').map(&:text)
        rows = doc.css('.table01 > tbody > tr')
        rows.each do |row|
          tds = row.css('td')
          tds.each_with_index do |td, td_index|
            begin
              img = td.css('img')
              next if img.empty?
              next unless td.css('img').try(:attr,'alt').try(:value) == "空"
              head_index = heads.size - tds.size + td_index
              available_date = heads[head_index]
              start_hour = available_date.split('-')[0].gsub(':00', "").to_i
              next unless [
                (date.wday == 0 && start_hour.between?(7, 18)),
                (date.wday.between?(1, 5) && (start_hour.between?(7, 8) || start_hour.between?(19,22))),
                (date.wday == 6 && start_hour.between?(7, 18))
              ].any?
              available_dates << "#{date.strftime("%Y/%m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} #{heads[head_index]}"
            rescue => e
              p "Error"
              p e
            end
          end
        end
      end
    rescue => e
      p "Error"
      p url
      p e
    end
  end
  date += 1
end


result = Set.new(available_dates).sort
puts result.join("\n")
pbcopy(result.join("\n"))
