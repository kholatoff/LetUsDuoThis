class SteamUser

    attr_reader :id
    attr_accessor :game_list, :username

    def initialize(id)
        @id = id
        @game_list = []
        @username = nil
    end

    def to_s()
        return "Steam user #{@id}"
    end

end