require 'uri'
require 'net/http'
require 'json'
require_relative 'user'
require_relative 'game'
require_relative 'exceptions'

class SteamClient

    def initialize (api_key)
        @api_key = api_key
    end

    public def get_user_friends(steam_id)
        uri = URI("http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=#{@api_key}&steamid=#{steam_id}&relationship=friend")
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
            users = []
            JSON.parse(res.body)["friendslist"]["friends"].each {
                |user_hash|
                user = SteamUser.new(user_hash["steamid"])
                users << user
            }

            return users
        else raise SteamHTTPException, "Could not get user friends!"
        end
    end

    public def get_user_games(steam_user)
        uri = URI("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{@api_key}&steamid=#{steam_user.id}&include_appinfo=true")
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
            games = []
            JSON.parse(res.body)["response"]["games"].each {
                |game_info|
                games << SteamGame.new(game_info["appid"], game_info["name"])
            }
            steam_user.game_list = games
        else raise SteamHTTPException, "Could not get user games!"
        end
    end

    public def check_coop(app_id)
        uri = URI("https://store.steampowered.com/api/appdetails?l=en&filters=categories&appids=#{app_id}")
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
            JSON.parse(res.body)["#{app_id}"]["data"]["categories"].each {
                |category|
                if category["id"] == 1 
                    return true
                end 
            }
            return false
        else raise SteamHTTPException, "Could not get game info!"
        end
    end

end