#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'




before do 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

configure do
	@db = SQLite3::Database.new 'blog.db'
	#@db.results_as_hash = true
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
		"id"	INTEGER,
		"created_date"	TEXT,
		"content"	TEXT,
		PRIMARY KEY("id" AUTOINCREMENT)
	);'

	@db.execute 'CREATE TABLE IF NOT EXISTS "Comments" (
		"id"	INTEGER,
		"created_date"	TEXT,
		"content"	TEXT,
		"post_id" INTEGER,
		PRIMARY KEY("id" AUTOINCREMENT)
	);'
	@db.close
end

get '/' do
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
	erb :index
end

get '/new' do
	erb :new			
end

post '/new' do

	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true

	@content = params[:content]
	if @content.size <= 0
		@error = 'Type post text!'
		return erb :new
	end
  
	@db.execute 'INSERT INTO Posts (created_date, content) VALUES (datetime(), ?)', [@content]
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
	erb :index
	
end


get '/post/:id' do

	id = params[:id]
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [id]
	@row = results[0]
	@comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [id]

	erb :post

end

post '/post/:id' do
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
	id = params[:id]
	content = params[:content]
	@db.execute 'INSERT INTO Comments (created_date, content, post_id) VALUES (datetime(), ?, ?)', [content, id]
	@comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [id]
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [id]
	@row = results[0]
	erb :post
end