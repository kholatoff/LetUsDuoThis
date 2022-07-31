require_relative 'SteamClient/client'
require_relative 'SteamClient/user'

class App 
    attr_accessor :client

    def initialize()
        @API_KEY = ENV["STEAM_API_KEY"]
        @client = SteamClient.new(@API_KEY)
    end

    def get_most_popular_games(user, friend_list)
        top_games = Hash.new(0)
        user.game_list.each{
            |game|
            friend_list.each{
                |friend|
                if friend.game_list.include?(game)
                    top_games[game] += 1
                end
            }
        }

        return top_games
    end

    def create_game_suggestions(top_games)
        game_suggestions = {}
        top_games.sort_by{|key, value| value}.reverse.each {
            |key, value|
            if @client.check_coop(key.id) == true 
                game_suggestions[key] = value
            end
            if game_suggestions.length >= 3 
                break
            end
        }

        return game_suggestions
    end

    def display_game_suggestions(game_suggestions)
        resulting_games = "Your top-3 suggestions are:\n"
        counter = 1
        game_suggestions.each{
            |key, value|
            resulting_games += "#{counter}) #{key.name} - #{value} of your friends play this game.\n"
            counter += 1
        } 
        puts resulting_games
    end

    def run()
        puts "
         __         __  __  __     ____            ________    _     
        / /   ___  / /_/ / / /____/ __ \\__  ______/_  __/ /_  (_)____
       / /   / _ \\/ __/ / / / ___/ / / / / / / __ \\/ / / __ \\/ / ___/
      / /___/  __/ /_/ /_/ (__  ) /_/ / /_/ / /_/ / / / / / / (__  ) 
     /_____/\\___/\\__/\\____/____/_____/\\__,_/\\____/_/ /_/ /_/_/____/  
                                                                     
        Welcome, User. Please, enter your Steam ID."
        id = gets.chomp
        user = SteamUser.new(id)
        
        friend_list = @client.get_user_friends(id)
        friend_list.each {
            |friend| 
            @client.get_user_games(friend)
        }
        @client.get_user_games(user)

        top_games = self.get_most_popular_games(user, friend_list)

        game_suggestions = self.create_game_suggestions(top_games)
        self.display_game_suggestions(game_suggestions)
    end
end

app = App.new()
app.run()