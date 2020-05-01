class Dog
    attr_accessor :id, :name, :breed
    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL

        sql2 = <<-SQL
        SELECT * FROM dogs
        ORDER BY id DESC
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name, breed)
        self.id = DB[:conn].execute(sql2)[0][0]
        self
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
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

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        dog = Hash[:id => row[0], :name => row[1], :breed => row[2]]
        self.new(dog)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        dog = DB[:conn].execute(sql, id)
        self.new_from_db(dog[0])

    end

    def self.find_or_create_by(dog_info)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
        dog = DB[:conn].execute(sql, dog_info[:name], dog_info[:breed])
        if dog[0]
            self.new_from_db(dog[0])
        else
            self.create(dog_info)
        end

    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql,name)
        self.new_from_db(dog[0])
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql,name,breed,id)
    end
end