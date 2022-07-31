class SteamGame

    attr_reader :id, :name

    def initialize(id, name)
        @id = id
        @name = name
    end

    def ==(other)
        self.name  == other.name 
    end
    
    def to_s()
        return "Steam game #{@name}"
    end

end