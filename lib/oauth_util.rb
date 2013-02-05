# A utility for signing an url using OAuth in a way that's convenient for debugging
# Note: the standard Ruby OAuth lib is here http://github.com/mojodna/oauth
# Source: http://gist.github.com/383159
# License: http://gist.github.com/375593
# Usage: see example.rb below
#
# NOTE: This file has been modified from the original Gist:
#
# 1. Fix to prevent param-array conversion, as mentioned in Gist comment.
# 2. Query string escaping has been changed. See:
#   https://github.com/alexreisner/geocoder/pull/360
#

require 'uri'
require 'cgi'
require 'openssl'
require 'base64'

class OauthUtil

  attr_accessor :consumer_key, :consumer_secret, :token, :token_secret, :req_method, 
                :sig_method, :oauth_version, :callback_url, :params, :req_url, :base_str

  def initialize
    @consumer_key = ''
    @consumer_secret = ''
    @token = ''
    @token_secret = ''
    @req_method = 'GET'
    @sig_method = 'HMAC-SHA1'
    @oauth_version = '1.0'
    @callback_url = ''
  end

  # openssl::random_bytes returns non-word chars, which need to be removed. using alt method to get length
  # ref http://snippets.dzone.com/posts/show/491
  def nonce
    Array.new( 5 ) { rand(256) }.pack('C*').unpack('H*').first
  end

  def percent_encode( string )

    # ref http://snippets.dzone.com/posts/show/1260
    return URI.escape( string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

  # @ref http://oauth.net/core/1.0/#rfc.section.9.2
  def signature
    key = percent_encode( @consumer_secret ) + '&' + percent_encode( @token_secret )

    # ref: http://blog.nathanielbibler.com/post/63031273/openssl-hmac-vs-ruby-hmac-benchmarks
    digest = OpenSSL::Digest::Digest.new( 'sha1' )
    hmac = OpenSSL::HMAC.digest( digest, key, @base_str )

    # ref http://groups.google.com/group/oauth-ruby/browse_thread/thread/9110ed8c8f3cae81
    Base64.encode64( hmac ).chomp.gsub( /\n/, '' )
  end

  # sort (very important as it affects the signature), concat, and percent encode
  # @ref http://oauth.net/core/1.0/#rfc.section.9.1.1
  # @ref http://oauth.net/core/1.0/#9.2.1
  # @ref http://oauth.net/core/1.0/#rfc.section.A.5.1
  def query_string
    pairs = []
    @params.sort.each { | key, val | 
      pairs.push( "#{ CGI.escape(key.to_s).gsub(/%(5B|5D)/n) { [$1].pack('H*') } }=#{ CGI.escape(val.to_s) }" )
    }
    pairs.join '&'
  end

  # organize params & create signature
  def sign( parsed_url )

    @params = {
      'oauth_consumer_key' => @consumer_key,
      'oauth_nonce' => nonce,
      'oauth_signature_method' => @sig_method,
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_version' => @oauth_version
    }

    # if url has query, merge key/values into params obj overwriting defaults
    if parsed_url.query
      CGI.parse( parsed_url.query ).each do |k,v|
        if v.is_a?(Array) && v.count == 1
          @params[k] = v.first
        else
          @params[k] = v
        end
      end
    end

    # @ref http://oauth.net/core/1.0/#rfc.section.9.1.2
    @req_url = parsed_url.scheme + '://' + parsed_url.host + parsed_url.path

    # create base str. make it an object attr for ez debugging
    # ref http://oauth.net/core/1.0/#anchor14
    @base_str = [ 
      @req_method, 
      percent_encode( req_url ), 

      # normalization is just x-www-form-urlencoded
      percent_encode( query_string ) 

    ].join( '&' )

    # add signature
    @params[ 'oauth_signature' ] = signature

    return self
  end
end
