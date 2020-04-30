class Dog
    attr_reader :id, :breed
    attr_accessor :name

    def initialize(id: nil, name:, breed:)
        @id = id
        self.name = name
        @breed = breed
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        # Check if it already exists via id, if so just update database, otherwise save into database
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
                SQL
            DB[:conn].execute(sql, [self.name, self.breed])
            # Pull database assinged id
            #binding.pry
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
            return self
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id == ?
            SQL
        DB[:conn].execute(sql, [self.name, self.breed, self.id])
        return self
    end

    def self.create(attributes_hash)
        self.new(attributes_hash).save
    end

    def self.new_from_db(db_row_array)
        self.create({id: db_row_array[0], name: db_row_array[1], breed: db_row_array[2]})
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id == ?
            SQL
        self.new_from_db(DB[:conn].execute(sql, [id]).first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name == ? AND breed == ?
            SQL
        dog = DB[:conn].execute(sql, [name, breed])
        attributes_hash = {name: name, breed: breed}
        # Check if a matching intance was found in the database, If  found then create a class instance but dont updates database
        if dog.any?
            attributes_hash[:id] = dog.first.first
            Dog.new(attributes_hash)
        # A matching instance was not found in the database, create it
        else
            self.create(attributes_hash)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name == ?
            SQL
        self.new_from_db(DB[:conn].execute(sql, [name]).first)
    end

end