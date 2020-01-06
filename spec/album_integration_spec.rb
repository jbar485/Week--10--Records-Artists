require('capybara/rspec')
require('./app')
Capybara.app = Sinatra::Application
set(:show_exceptions, false)

describe('create an album path', {:type => :feature}) do
  it('creates an album and then goes to the album page') do
    visit('/albums')
    click_on('Add a new album')
    fill_in('album_name', :with => 'Yellow Submarine')
    fill_in('album_artist', :with => 'The Beatles')
    fill_in('album_year', :with => '1966')
    fill_in('album_cost', :with => 0.05)
    click_on('Go!')
    save_and_open_page
    expect(page).to have_content("Yellow")
  end
end
