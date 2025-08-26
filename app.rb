require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "rack/contrib/json_body_parser"
require "sinatra/contrib"

use Rack::JSONBodyParser






get("/") do
  erb(:home)
end

get("/game") do

  
  new_deck = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"

  resp = HTTP.get(new_deck)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  deck = parsed_response.fetch("deck_id")

  cookies[:deck_id] = deck

  #start game by drawing 7 cards
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=7"

resp = HTTP.get(start_game)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  cards = parsed_response.fetch("cards")

  @card_arr = []

  @code_arr = []
  cards.each do |c| 
    @card_arr.push(c.fetch("image"))

    @code_arr.push(c.fetch("code"))
  end

  #discard = "AS" #change to be user input somehow maybe find a way to see if i can make it so the cards are clickable

  #pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/discard/add/?cards=" + discard
  
  erb(:game)

end


get("/discard") do


  @checked = []
  discard = []
  params.each do |key, val|
    @checked.push(key)
    discard = discard + key
  end

  deck = cookies[:deck_id]

  

  #/pile/discard is name of pile - its discard
pile_name = "discard"

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discard

  resp = HTTP.get(pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"


resp = HTTP.get(pile_list)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

 cards = parsed_response.fetch("piles").fetch("discard").fetch("cards")

  @pile_arr = []

  
  cards.each do |c| 
    @pile_arr.push(c.fetch("image"))

    @code = c.fetch("code")
  end

  erb(:discard)

end

get("/checked") do

  params.each do |p|
    console.log(p)
  end
  erb(:checked)

end
