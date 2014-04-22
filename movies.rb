require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  erb :search
end


get '/results' do
              # VERY IMPORTANT- :host must be set to "" instead of "localhost"
  c = PGconn.new(:host => "", :dbname => dbname)
  @movies = c.exec_params("SELECT * FROM movies WHERE title ILIKE $1;", [params[:movie]])
  c.close                                             #user ILIKE instead of = to make a case
                                                      # insensitive search!
  
  erb :results
end


#add /details
get '/details/:id' do
  c = PGconn.new(:host => "", :dbname => dbname)
  @movies = c.exec_params("SELECT * FROM movies WHERE id =$1;", [params[:id]])
  @title=@movies[0]["title"]
  @year=@movies[0]["year"]
  @plot=@movies[0]["plot"]
  @genre=@movies[0]["genre"]
  erb :details

end



get '/movies/new' do
  erb :new
end

post '/movies' do
  c = PGconn.new(:host => "", :dbname => dbname)
  c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2)",
                  [params["title"], params["year"]])
  c.close
  redirect '/'
end

def dbname
  "moviesdb"
end

def create_movies_table
  connection = PGconn.new(:host => "", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "", :dbname => dbname)
  connection.exec "DROP TABLE movies;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

