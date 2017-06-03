# coding: utf-8

require "yaml"
require "slack-ruby-client"
require "rufus-scheduler"
require_relative "./voting"

conf = YAML.load_file(File.expand_path("./config.yml", __dir__))
Slack.configure do |c|
  c.token = conf["token"]
end

wc = Slack::Web::Client.new
rtc = Slack::RealTime::Client.new
scheduler = Rufus::Scheduler.new

vconf = conf["voting"]
voting = nil
scheduler.cron vconf["start"] do
  voting = Voting.new(vconf["targets"])
  wc.chat_postMessage(
    channel: vconf["channel"],
    text: "投票開始\n---\n#{vconf["targets"].join("\n")}",
    as_user: true
  )
end
scheduler.cron vconf["end"] do
  wc.chat_postMessage(
    channel: vconf["channel"],
    text: "投票結果\n---\n#{voting.finish.map {|k, v| "#{k}: #{v}"}.join("\n")}",
    as_user: true
  )
  voting = nil
end

rtc.on :hello do
  puts "#{conf["name"]} start"
end
rtc.on :message do |data|
  t = data.text
  if t == "#{conf["name"]} sample"
    sample = conf["samples"].sample
    rtc.message channel: data.channel, text: "<@#{sample}>"
  elsif t == "#{conf["name"]} ping"
    rtc.message channel: data.channel, text: "pong"
  elsif m = t.match(/^#{conf["name"]} vote (\S+)$/)
    if voting
      begin
        voting.vote(data.user, m[1])
        rtc.message channel: data.channel, text: "受付"
      rescue
        rtc.message channel: data.channel, text: "無効"
      end
    else
      rtc.message channel: data.channel, text: "開始前"
    end
  end
end

begin
  rtc.start!
rescue Interrupt
end
