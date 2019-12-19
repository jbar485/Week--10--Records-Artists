class Album

  @@albums = {}
  @@total_rows = 0

  attr_reader :id, :name, :year, :genre, :artist

  def initialize(name, artist, year, genre, id)
    @name = name
    @artist = artist
    @year = year
    @genre = genre
    @id = id || @@total_rows += 1
  end

  def self.all()
    @@albums.values
  end

  def save()
    @@albums[self.id] = Album.new(self.name, self.artist, self.year, self.genre, self.id)
  end

  def ==(other_album)
    self.name.eql?(other_album.name)
    self.artist.eql?(other_album.artist)
    self.year.eql?(other_album.year)
  end

  def self.clear
    @@albums = {}
    @@total_rows = 0
  end

  def self.find(id)
    @@albums[id]
  end

  def update(name, artist, year, genre)
    @name = (name == '') ? self.name : name
    @artist = (artist == '') ? self.artist : artist
    @year = (year == '') ? self.year : year
    @genre = (genre == 'noChange') ? self.genre : genre
  end

  def delete
    @@albums.delete(self.id)
  end

  def self.sorted()
    Album.all.sort_by { |album| album.name }
  end

  def self.search(query)
    Album.sorted.select { |album| album.name.match?(/(#{query})/i)}
  end

  def songs
    Song.find_by_album(self.id)
  end
end
