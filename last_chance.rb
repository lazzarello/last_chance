#!/usr/bin/ruby
require 'rubygems'
require 'open-uri'
require 'rexml/document'
require 'mp3info'
require 'cgi'
require 'httpclient'
require 'fileutils'
require 'tempfile'

include REXML
include FileUtils

# define some constants
KEY = ARGV[0] # artist, title, some other stuff
VALUE = CGI.escape(ARGV[1])

# authentication
USERNAME = ""
PASSWORD = ""
CLIENT_VERSION = "1.5.3.45507"
SET_AUTH = "/radio/handshake.php?version=#{CLIENT_VERSION}&platform=mac&platformversion=Mac%20OS%20X%2010.5&username=#{USERNAME}&passwordmd5=#{PASSWORD}&language=en"
# web services hostnames
HOSTS = {:ws => 'ws.audioscrobbler.com', 
	 :post => 'post.audioscrobbler.com', 
	 :play => 'play.last.fm'}
AUTH_INFO = {}
# ha! fake!
USERAGENT = "Last.fm Client #{CLIENT_VERSION} (OS X)"
PLAYLIST_INFO = {}
# this will become an array of hashes
PLAYLIST = []

CLIENT = HTTPClient.new

def authenticate(url, client)
  client.get_content(url) do |f|
    f.each_line do |l|
      l.chomp!
      h = l.split "="
      AUTH_INFO[h.first] = h.last
    end
  end
end

def set_playlist(url, client)
  client.get_content(url) do |f|
    f.each_line do |l|
      l.chomp!
      h = l.split "="
      PLAYLIST_INFO[h.first] = h.last
    end
  end
end

def get_playlist(url)
  f = open(url) 
  playlist = Document.new(f)
  root = playlist.root
  root.each_element('//track') do |track|
    # this is an array of hashes. it's insanity.
    song = {
    :location => track.elements['location'].text,
    :title => track.elements['title'].text,
    :artist => track.elements['creator'].text,
    :album => track.elements['album'].text
    }
    PLAYLIST << song
  end
end

def download_songs(hash, client)
  hash.map do |h|
    # http://onrails.org/articles/2007/05/21/bloated-railsconf-presentation-downloader
    # http://dev.ctor.org/doc/httpclient/
    p "Recording teh awesome song named #{h[:title]}"
    dir = "#{ENV['HOME']}/sounds/#{h[:artist]}/#{h[:album]}"
    Tempfile.open("temp.mp3", "/tmp") do |f| 
      f.write(client.get_content("#{h[:location]}"))
      mkdir_p dir
      cp f.path, "#{dir}/#{h[:title]}.mp3"
    end
    tag_songs("#{dir}/#{h[:title]}.mp3", h[:title], h[:artist], h[:album])
  end
end

def tag_songs(mp3file, title, artist, album)
  mp3 = Mp3Info.open("#{mp3file}")
  mp3.tag.title = title 
  mp3.tag.artist = artist
  mp3.tag.album = album
  mp3.close
end

def main
  authenticate("http://#{HOSTS[:ws]}#{SET_AUTH}", CLIENT)
  AUTH_INFO.map { |k,v| puts "#{k}=#{v}" }
  puts "_______"
  set_playlist_url = "/radio/adjust.php?session=#{AUTH_INFO['session']}&url=lastfm://#{KEY}/#{VALUE}/similarartists&lang=en"
  set_playlist("http://#{HOSTS[:ws]}#{set_playlist_url}", CLIENT)
  PLAYLIST_INFO.map { |k,v| puts "#{k}=#{v}" }
  puts "_______"
  get_playlist_url = "/radio/xspf.php?sk=#{AUTH_INFO['session']}&discovery=0&desktop=#{CLIENT_VERSION}"
  get_playlist("http://#{HOSTS[:ws]}#{get_playlist_url}")
  download_songs(PLAYLIST, CLIENT)
  p "Download complete"
end
main
