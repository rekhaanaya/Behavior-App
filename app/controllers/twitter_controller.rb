

class TwitterController < ApplicationController


before_filter :authenticate_user!


def generate_twitter_oauth_url
		oauth_callback = "http://#{request.host}:#{request.port}/oauth_account"
 
		@consumer = OAuth::Consumer.new("SmlhrQGtSEL8T1arCMX0w","JRgtgF3tw2MNzGkAoIMEjtrCqAuDznfDzDXgBleKcc", :site => "https://api.twitter.com")
 
  	        @request_token = @consumer.get_request_token(:oauth_callback => oauth_callback)
	 	session[:request_token] = @request_token
 
		redirect_to @request_token.authorize_url(:oauth_callback => oauth_callback)
	end



def oauth_account
		if TwitterOauthSetting.find_by_user_id(current_user.id).nil?
			@request_token = session[:request_token]
			@access_token = @request_token.get_access_token(:oauth_verifier => params["oauth_verifier"])
      TwitterOauthSetting.create(atoken: @access_token.token, asecret: @access_token.secret, user_id: current_user.id)
			update_user_account()
               end
		redirect_to "/twitter_profile"
        end



def index
    unless TwitterOauthSetting.find_by_user_id(current_user.id).nil?
      redirect_to "/twitter_profile"
    end
end



def get_client
		Twitter.configure do |config|
		  config.consumer_key = "SmlhrQGtSEL8T1arCMX0w"
		  config.consumer_secret = "JRgtgF3tw2MNzGkAoIMEjtrCqAuDznfDzDXgBleKcc"
		end
 
		Twitter::Client.new(
		  :oauth_token => TwitterOauthSetting.find_by_user_id(current_user.id).atoken,
		  :oauth_token_secret => TwitterOauthSetting.find_by_user_id(current_user.id).asecret
		)
	end


def twitter_profile
  @user_timeline = get_client.user_timeline(:count => 500)

  @user_timeline.collect do |t|

      tweet = Tweet.create do |u|
        u.text = t.text.to_s
        u.user_id = current_user.id
      end
end

       @home_timeline = get_client.home_timeline
  end

      def show
      @user_timeline = get_client.user_timeline(:count => 500)
      #@user_timeline.collect do |t|
      h = Hash.new
      @user_timeline.each do |t|
      @words = t.text.to_s.split
        @words.each { |w|

          if h.has_key?(w)
            h[w] = h[w] + 1
          else
            h[w] = 1
          end


        }

      end
      h.sort{|a,b| a[1]<=>b[1]}.each { |elem|
        puts "\"#{elem[0]}\" => #{elem[1]} "
      }


      end












def update_user_account
	  user_twitter_profile = get_client.user
	  current_user.update_attributes({
	    name: user_twitter_profile.name, 
	    screen_name: user_twitter_profile.screen_name, 
	    url: user_twitter_profile.url, 
	    profile_image_url: user_twitter_profile.profile_image_url, 
	    location: user_twitter_profile.location, 
	    description: user_twitter_profile.description,


	  })
	end






end
