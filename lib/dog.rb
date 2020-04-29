class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        sql2 = <<-SQL
        SELECT *
        FROM dogs
        ORDER BY id DESC
        LIMIT 1
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute(sql2)[0][0]
        self
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(dog_info)
        new_dog = self.new(dog_info)
        new_dog.save
    end

    def self.new_from_db(row_info)
        self.new({id:row_info[0], name:row_info[1], breed:row_info[2]})
    end

    def self.find_by_id(dog_id)
        self.all.find {|dog| dog.id == dog_id}
    end

    def self.find_or_create_by(dog_info)
        dog = self.all.find {|dog| dog.name == dog_info[:name] and dog.breed == dog_info[:breed]}
        if dog != nil
            dog
        else
            self.create(dog_info)
        end
    end

    def self.find_by_name(dog_name)
        self.all.find {|dog| dog.name == dog_name}
    end

    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs
        SQL

        dogs = DB[:conn].execute(sql)
        dogs.map {|dog| self.new_from_db(dog)}
    end
end