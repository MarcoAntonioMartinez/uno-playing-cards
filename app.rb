require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "rack/contrib/json_body_parser"
require "sinatra/contrib"

use Rack::JSONBodyParser
=begin
pile_name = "draw"

cookies[:deck_id] = deck

pile = "https://deckofcardsapi.com/api/deck/" +  "/pile/" + pile_name + "/add/?cards=" + 

  resp = HTTP.get(new_deck)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  deck = parsed_response.fetch("deck_id")

=end 




get("/") do
  erb(:home)
end

get("/game") do
#each time go back to this page the cards change maybe have to fix  maybe just move all the start game code outside of this action
  
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
  
    cookies[:hand] = (@code_arr.join(",")) 
  end

  ######################################## draw from whole deck to add to pile

deck_draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=45"

resp = HTTP.get(deck_draw)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  deck_cards = parsed_response.fetch("cards")

  @deck_arr = []

  @deck_code_arr = []
  
  
  deck_cards.each do |c| 
    @deck_code_arr.push(c.fetch("code"))
  end

  deck_pile = @deck_code_arr.join(",")

  pile_name = "draw"

# create new pile draw which contains whole rest of deck
pile = "https://deckofcardsapi.com/api/deck/" + deck +  "/pile/" + pile_name + "/add/?cards=" + deck_pile 

  resp = HTTP.get(pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)


   pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

resp = HTTP.get(pile_list)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  draw_pile = parsed_response.fetch("piles").fetch("draw").fetch("cards")
=begin
  draw_cards.each do |c| 
    @deck_code_arr.push(c.fetch("code"))
  end

  deck_pile = @deck_code_arr.join(",")

=end  



  #discard = "AS" #change to be user input somehow maybe find a way to see if i can make it so the cards are clickable

  #pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/discard/add/?cards=" + discard
  
  erb(:game)

end


get("/discard") do

#has the chosen cards to be discarded
  @checked = []
  @discard = ""
  params.each do |key, val|
    @checked.push(key)
    @discard = @checked.join(",")
  end

  deck = cookies[:deck_id]

  #array of the cards in hand
  hand_arr = cookies[:hand].split(",")

  #string of hand cards
  hand = cookies[:hand]
  new_hand_arr = []

  new_hand = ""

  #check what card(s) were discarded from hand and change hand accordingly
  hand_arr.each do |h|
    if @checked.include?(h)
      new_hand_arr.push(h)
    end
 
    
  end

  new_hand = new_hand_arr.join(",")

  ## ################# hand pile            maybe i dont need to get the parsed response when im adding cards to piles
  
  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + hand

  resp = HTTP.get(@pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)



  #drawing from pile discards from pile


  #draw from the pile which would be discarding in this case
  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard

  resp = HTTP.get(pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)


  pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"


resp = HTTP.get(pile_list)

  raw_response = resp.to_s

  
  @parsed_response = JSON.parse(raw_response)


 @cards = @parsed_response.fetch("piles").fetch("hand").fetch("cards")

  @hand_arr = []

  @hand_code = []
  @cards.each do |c| 
    @hand_arr.push(c.fetch("image"))

    @hand_code.push(c.fetch("code"))
  end

  

  
############# end of hand pile

  #/pile/discard is name of pile - its discard
pile_name = "discard"

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @discard

  resp = HTTP.get(pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"


resp = HTTP.get(pile_list)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

 cards = parsed_response.fetch("piles").fetch("discard").fetch("cards")

  @pile_arr = []

  @code_arr = []
  cards.each do |c| 
    @pile_arr.push(c.fetch("image"))

    @code_arr.push(c.fetch("code"))
  end

  erb(:discard)

end

get("/checked") do

  params.each do |p|
    console.log(p)
  end
  erb(:checked)

end
