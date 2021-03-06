#encoding: utf-8

# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'nokogiri'

def get_news(gid)
  # Read in a page
  url = "https://docs.google.com/spreadsheets/d/1AWDMIZsE9k3jQaJlgCKBt8vwVHg4Tg4MqHd-09CRc6I/pubhtml?gid="+gid+"&single=true"
  page = Nokogiri::HTML(open(url), nil, 'utf-8')
  rows = page.xpath('//table[@class="waffle"]/tbody/tr')

  # Find somehing on the page using css selectors
  content = []
  rows.collect do |r|
    content << r.xpath('td').map { |td| td.text.strip }
  end

  content.shift
  # p content
  content.each do |row|
    if row[2] != ""
      record = {
        "id" => Digest::SHA1.hexdigest(row[6].gsub(/\s+/, "")),
        "fecha" => row[0],
        "medio" => row[1],
        "titular" => row[2],
        "imagen" => row[3],
        "bajada" => row[4],
        "tipo_prensa" => row[5],
        "link" => row[6],
        "temas" => row[7],
        "observaciones" => row[8],
        "prensa_internacional" => row[9],
        "destacada" => row[10],
        "created_at" => Date.today.to_s
      }

      # Storage records
      if ((ScraperWiki.select("* from data where `id`='#{record['id']}'").empty?) rescue true)
        ScraperWiki.save_sqlite(["id"], record)
        puts "Adds new record from " + record['id']
      else
        ScraperWiki.save_sqlite(["id"], record)
        puts "Updating already saved record from " + record['id']
      end
    end
  end
end

a_gid = ['494757158','1616582078','1546052280','1989196281']
a_gid.each do | gid |
  get_news(gid);
end

# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
