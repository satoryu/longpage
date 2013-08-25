# encoding: utf-8

require 'bundler'
Bundler.require

Dotenv.load

Capybara.current_driver = :webkit
Capybara.run_server = false
#Capybara.app_host = 'http://www.rakuten.co.jp'

require 'capybara/dsl'

RakutenWebService.configuration do |c|
  c.application_id = ENV['APPLICATION_ID']
end

require 'uri'

class LongpageChecker
  include Capybara::DSL

  class << self
    def run(options={})
      self.new.run
    end
  end

  def run
    RWS::Ichiba::Item.ranking({}).each do |item|
      using_wait_time(30) do
        visit item.url
      end
      page.execute_script(<<-JS)
        (function() { 
          var height = document.height;
          var div = document.createElement("div");
          div.id = "longpage_checker";
          div.innerText = height.toString();
          document.body.appendChild(div);
        })();
      JS
      height = page.find('#longpage_checker').text

      puts "#{item.rank}位 #{height}px #{item.name[0..50]} "
    end
  end
end

LongpageChecker.run
