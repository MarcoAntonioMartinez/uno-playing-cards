require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "rack/contrib/json_body_parser"

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

  #start game by drawing 7 cards
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=7"

resp = HTTP.get(start_game)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  cards = parsed_response.fetch("cards")

  @card_arr = []

  cards.each do |c| 
    @card_arr.push(c.fetch("image"))
  end

  #discard = "AS" #change to be user input somehow maybe find a way to see if i can make it so the cards are clickable

  #pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/discard/add/?cards=" + discard

  erb(:game)

end


# The POST route that receives the data from JavaScript
post ("/api/process-click") do

  json = JSON.parse(request.body.read)
  console.log(json)

  # Access the data sent from the client via the `params` hash.
  clicked_item = params['item']

  # Process the data (e.g., log it or save it to a database).
  console.log("Received click for item: #{clicked_item}")

  # Send a JSON response back to the client.
  content_type :json
  { message: "Server received: '#{clicked_item}'" }.to_json
end

post ("/game") do

  json = JSON.parse(request.body.read)
  console.log(json)

  # Access the data sent from the client via the `params` hash.
  clicked_item = params['item']

  # Process the data (e.g., log it or save it to a database).
  console.log("Received click for item: #{clicked_item}")

  # Send a JSON response back to the client.
  content_type :json
  { message: "Server received: '#{clicked_item}'" }.to_json
end
