require('sinatra')
require('sinatra/reloader')
require('pry')
require('./lib/album')
require('./lib/song')
require('./lib/artist')
require('pg')

DB = PG.connect({:dbname => "record_store"})

also_reload('lib/**/*.rb')

# Root
get('/') do
  @albums = Album.sorted
  redirect to('/albums')
end

#Album Requests

get('/albums') do
  @artists = Artist.sorted
  @albums = Album.sorted
  erb(:albums)
end

post('/albums') do
  artist = Artist.find(params[:album_artist])
  name = params[:album_name]
  year = params[:album_year]
  genre = params[:album_genre]
  cost = params[:album_cost]
  album = Album.new({:name => name, :artist => artist.name, :year => year, :genre => genre, :cost => cost, :id => nil})
  album.save()
  artist.update({:album_name => name})
  @albums = Album.sorted

  erb(:albums)
end

get('/albums/new') do
  @artists = Artist.all
  erb(:new_album)
end

get('/albums/destroy') do
  Album.clear
  redirect to('/albums')
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
  @album.update(params[:album_name], params[:album_artist], params[:album_year], params[:album_genre], params[:album_cost])

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

get('/sort_cost') do
  @albums = Album.sort_cost
  erb(:albums)
end

get('/sort_cost_descending') do
  @albums = Album.sort_cost_descending
  erb(:albums)
end

get('/sort_year') do
  @albums = Album.sort_year
  erb(:albums)
end

get('/sort_year_descending') do
  @albums = Album.sort_year_descending
  erb(:albums)
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

# artist views

get('/artists') do
  @artists = Artist.sorted
  erb(:artists)
end
get('/artists/new') do
  erb(:new_artist)
end

post('/artists') do
  name = params[:artist_name]
  artist = Artist.new({:name => name, :id => nil})
  artist.save()
  @artists = Artist.sorted
  erb(:artists)
end

get('/artists/:id') do
  @artist= Artist.find(params[:id].to_i())
  @albums = @artist.albums
  erb(:artist)
end

patch('/artists/:id') do
  @artist = Artist.find(params[:id].to_i())
  @artist.update(params[:artist_name])
  @artists = Artist.sorted
  erb(:artists)
end

delete('/artists/:id') do
  @artist = Artist.find(params[:id].to_i())
  @artist.delete()
  @artists = Artist.sorted
  erb(:artists)
end
