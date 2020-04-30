class Dog
    attr_accessor :name, :breed, :id


    # attr = {}

    def initialize(attr)
        attr.each {|k, v| self.send(("#{k}="), v)}

    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs 
            (id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        self
    end

    def self.create(attr)
        new(attr).save

    end

    def self.new_from_db(row)
        Dog.new(Hash[[:id, :name, :breed].zip(row)])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            new_from_db(row)
        end.first
    end

   def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
     if !dog.empty?
        doggy = new_from_db(dog[0])
     else
        doggy = create(name: name, breed: breed)
     end
     doggy
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map {|row| new_from_db(row)}.first
        
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, @name, @album, @id)
    end
    
end