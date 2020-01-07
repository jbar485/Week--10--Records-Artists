class Artist

  attr_accessor :name
  attr_reader :id

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @name = attributes.fetch(:name)
  end

  def self.all()
    returned_artists = DB.exec("SELECT * FROM artists;")
    artists = []
    returned_artists.each() do |artist|
      id = artist.fetch("id").to_i
      name = artist.fetch("name")
      artists.push(Artist.new({:id => id, :name => name}))
    end
    artists
  end

  def save()
    result = DB.exec("INSERT INTO artists (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(other_artist)
    if self.name.eql?(other_artist.name)
      true
    else
      false
    end
  end

  def self.clear
    DB.exec("DELETE FROM artists *;")
  end

  def self.find(id)
    artist = DB.exec("SELECT * FROM artists WHERE id = #{id};").first
    id = artist.fetch("id").to_i
    name = artist.fetch("name")

    Artist.new({:id => id, :name => name})
  end

  def update(attributes)
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name)
      DB.exec("UPDATE artists SET name = '#{@name}' WHERE id = #{@id};")
    end
    album_name = attributes.fetch(:album_name)
    if album_name != nil
      album = DB.exec("SELECT * FROM albums WHERE lower(name)='#{album_name.downcase}';").first
      if album != nil
        DB.exec("INSERT INTO albums_artists (album_id, artist_id) VALUES (#{album['id'].to_i}, #{@id});")
      end
    end
  end

  def delete
    DB.exec("DELETE FROM albums_artists WHERE artist_id = #{@id};")
    DB.exec("DELETE FROM artists WHERE id = #{@id};")
  end

  def self.sorted()
    Artist.all.sort_by { |artist| artist.name }
  end

  def self.search(query)
    Artist.sorted.select { |artist| artist.name.match?(/(#{query})/i)}
  end

  def albums
    albums = []
    results = DB.exec("SELECT album_id FROM albums_artists WHERE artist_id = #{@id};")
    results.each() do |result|
      album_id = result.fetch("album_id").to_i()
      album = DB.exec("SELECT * FROM albums WHERE id = #{album_id};")
      name = album.first().fetch("name")
      artist = album.first().fetch("artist")
      year = album.first().fetch("year")
      genre = album.first().fetch("genre")
      cost = album.first().fetch("cost")
      albums.push(Album.new({:name => name, :id => album_id, :artist => artist, :year => year, :genre => genre, :cost => cost}))
    end
    albums
  end

end
