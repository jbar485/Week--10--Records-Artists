class Album

  attr_accessor :name, :artist, :year, :genre, :cost
  attr_reader :id

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @name = attributes.fetch(:name)
    @artist = attributes.fetch(:artist)
    @year = attributes.fetch(:year)
    @genre = attributes.fetch(:genre)
    @cost = attributes.fetch(:cost)
  end

  def self.all()
    returned_albums = DB.exec("SELECT * FROM albums;")
    albums = []
    returned_albums.each() do |album|
      id = album.fetch("id").to_i
      name = album.fetch("name")
      artist = album.fetch("artist")
      year = album.fetch("year")
      genre = album.fetch("genre")
      cost = album.fetch("cost")
      albums.push(Album.new({:id => id, :name => name, :artist => artist, :year => year, :genre => genre, :cost => cost }))
    end
    albums
  end

  def save()
    result = DB.exec("INSERT INTO albums (name, artist, year, genre, cost) VALUES ('#{@name}', '#{@artist}', '#{@year}', '#{@genre}', #{@cost}) RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(other_album)
    if self.name.eql?(other_album.name) && self.artist.eql?(other_album.artist) && self.year.eql?(other_album.year)
      true
    else
      false
    end
  end

  def self.clear
    DB.exec("DELETE FROM albums *;")
  end

  def self.find(id)
    album = DB.exec("SELECT * FROM albums WHERE id = #{id};").first
    id = album.fetch("id").to_i
    name = album.fetch("name")
    artist = album.fetch("artist")
    year = album.fetch("year")
    genre = album.fetch("genre")
    cost = album.fetch("cost")
    Album.new({:id => id, :name => name, :artist => artist, :year => year, :genre => genre, :cost => cost })
  end

  def update(name, artist, year, genre, cost)
    if name != ''
      @name = name
    end
    @artist = (artist == '') ? self.artist : artist
    @year = (year == '') ? self.year : year
    @cost = (cost == '') ? self.cost : cost
    @genre = (genre == 'noChange') ? self.genre : genre
    DB.exec("UPDATE albums SET name = '#{@name}', artist = '#{@artist}', year = '#{@year}', genre = '#{@genre}', cost = '#{cost}' WHERE id = #{@id};")
  end

  def delete
    DB.exec("DELETE FROM albums WHERE id = #{@id};")
    DB.exec("DELETE FROM songs WHERE album_id = #{@id};")
  end

  def self.sorted()
    Album.all.sort_by { |album| album.name }
  end

  def self.sort_cost
    Album.all.sort_by{ |album| album.cost}
  end

  def self.sort_cost_descending
    Album.all.sort_by{ |album| album.cost}.reverse
  end

  def self.sort_year
    Album.all.sort_by{ |album| album.year}
  end

  def self.sort_year_descending
    Album.all.sort_by{ |album| album.year}.reverse
  end

  def self.search(query)
    Album.sorted.select { |album| album.name.match?(/(#{query})/i)}
  end

  def songs
    Song.find_by_album(self.id)
  end
end
