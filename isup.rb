require 'sinatra'
require 'rubygems'
require "net/http"
require "net/https"
require "uri"
require "json"
require 'whois'

def fetch(uri_str, limit = 10)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
  if response = Net::HTTP.get_response(URI(uri_str))
    case response
    when Net::HTTPSuccess then
      response
    when Net::HTTPRedirection then
      location = response['location']
  #   #warn "redirected to #{location}"
      $redirects << location
      fetch(location, limit - 1)
    else
      response.value
    end
  end
end

get '/' do
  "I guess instructions go here..."
end

get '/stats' do
  "Stats will eventually live here"
end

get '/stats/:domain' do
  "Stats will eventually live here for #{params[:domain]}"
end

get %r{/isup/(.*)} do
  rawdomain = "#{params[:captures].first}"

  $redirects = Array.new
  domain = rawdomain.split(/:\/\/?/)[-1]
  if Whois.whois(domain).registered?
    domain = 'http://' + domain
    if domain =~ /^#{URI::regexp}$/
      result = fetch(domain)
      output = {
        'isup_status' => 'SUCCESS',
        'uri' => rawdomain,
        'domain' => domain,
        'code' => result.code,
        'status' => result.message,
        'redirects' => $redirects,
      }
   else
     output = {
       'isup_status' => 'ERROR_INCORRECT_URI',
     }
  end
  else
    output = {
      'isup_status' => 'ERROR_DOMAIN_NOT_REGISTERED',
    }
  end
c = Whois.whois(domain).registered?
print c
  output.to_json
end

not_found do
  'wat'
end

#add in stats to db (incremement one per search) and then call on the stats page 
# PK is domain count is count


