require('sinatra')
require('sinatra/reloader')
require('pry')
require('./lib/album')
require('./lib/song')
require('pg')

DB = PG.connect({:dbname => "record_store"})

also_reload('lib/**/*.rb')

# Root
get('/') do
  @albums = Album.sorted
  erb(:albums)
end

#Album Requests

get('/albums') do
  @albums = Album.sorted
  erb(:albums)
end

post('/albums') do
  name = params[:album_name]
  artist = params[:album_artist]
  year = params[:album_year]
  genre = params[:album_genre]

  album = Album.new({:name => name, :artist => artist, :year => year, :genre => genre, :id => nil})
  album.save()
  @albums = Album.sorted
  erb(:albums)
end

get('/albums/new') do
  erb(:new_album)
end

get('/albums/:id') do
  @album = Album.find(params[:id].to_i())
  erb(:album)
end

get('/albums/:id/edit') do
  @album = Album.find(params[:id].to_i())
  erb(:edit_album)
end

patch('/albums/:id') do
  @album = Album.find(params[:id].to_i())
  @album.update(params[:album_name], params[:album_artist], params[:album_year], params[:album_genre])

  @albums = Album.sorted
  erb(:albums)
end

delete('/albums/:id') do
  @album = Album.find(params[:id].to_i())
  @album.delete()
  @albums = Album.sorted
  erb(:albums)
end

get('/search') do
  @search = params[:query]
  @albums = Album.search(params[:query])
  erb(:search)
end

# Song Requests

get('/albums/:id/songs/:song_id') do #Song Details
  @song = Song.find(params[:song_id].to_i())
  @album = Album.find(params[:id].to_i())
  if @song != nil
    erb(:song)
  else
    erb(:error_page)
  end
end

post('/albums/:id/songs') do #add a new song
  @album = Album.find(params[:id].to_i())
  song = Song.new({:name => params[:song_name],:album_id => @album.id, :id => nil})
  song.save()
  erb(:album)
end

patch('/albums/:id/songs/:song_id') do #update a single song
  @album = Album.find(params[:id].to_i())
  song = Song.find(params[:song_id].to_i())
  song.update(params[:name], @album.id)
  erb(:album)
end

delete('/albums/:id/songs/:song_id') do #delete a song from albums
  song = Song.find(params[:song_id].to_i())
  song.delete
  @album = Album.find(params[:id].to_i())
  erb(:album)
end
