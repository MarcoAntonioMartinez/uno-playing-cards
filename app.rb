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

# idk if i should go and replace the code with this function now or later ill find out i guess
def api_response(url, key)
  resp = HTTP.get(url)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  #so i dont have to basically make a variable the same as parsed response on line 33 (2 lines above here)
  return fetched_key = parsed_response.fetch(key)

  #return fetched_key
end

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

  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cookies[:hand]

  resp = HTTP.get(@pile)

  ################################################### end of making new deck and hand

  ################################################### start of adding player 2 to game in other words the bot - goes in game
  ################################################### end of adding player 2 to game in other words the bot - goes in game

  ######################################## draw from whole deck to add to pile  -> not right i dont need to add a whole pile I can just draw from deck and add it to pile idk why i thought i needed this

=begin create new pile draw which contains whole rest of deck -> not right i dont need to add a whole pile I can just draw from deck and add it to pile idk why i thought i needed this
pile = "https://deckofcardsapi.com/api/deck/" + deck +  "/pile/" + pile_name + "/add/?cards=" + deck_pile 

  resp = HTTP.get(pile)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)


   pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

resp = HTTP.get(pile_list)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  draw_pile = parsed_response.fetch("piles").fetch("draw").fetch("cards")

  draw_cards.each do |c| 
    @deck_code_arr.push(c.fetch("code"))
  end

  deck_pile = @deck_code_arr.join(",")
=end

  ################################################### start of take top card from deck and place on discard pile which starts the game - place on game action

  @game_starting_draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=1"

  #need to get first card
  @first_card = api_response(@game_starting_draw, "cards")
  #@first_card[0]

  @first_card.each do |c|
    @card = c.fetch("image")

    @code = c.fetch("code")

    @value = c.fetch("value")

    @suit = c.fetch("suit")
  end

  # need to add to discard pile
  pile_name = "discard"

  first_discard = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code

  #adds first card to discard pile
  resp = HTTP.get(first_discard)

  # need to add to pile
  pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  
  #make it so the cards that do not match the most recent card are disabled

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []
  #has code for cards in hand
  cards.each do |c|

    #this code should still work with this project I think i just need to change the whole thing from checkboxes to radio buttons bc i only need to choose one
    if !(c.fetch("value") == @value || c.fetch("suit") == @suit || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
      @disabled_arr.push(c)
    end

    if @disabled_arr.include?(c)
      @disable.push(true)
    else
      @disable.push(false)
    end
  end

  #if all cards are disabled then draw from deck
  c = cards.join(",")
  d = @disabled_arr.join(",")

  cookies[:add_card] = false
  #maybe this part needs to be in draw action
  #how to make this true when button is pressed

  #if c == d

  ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action
  draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=1"
  new_card = api_response(draw, "cards")

  new_card.each do |n|
    @code = n.fetch("code")
  end

  pile_name = "hand"
  add_hand = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code
  resp = HTTP.get(add_hand)

  ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action

  ################################################### end of take top card from deck and place on discard pile which starts the game - place on game action

  ################################################### start of discard only 1 card at a time - place on game action
  ################################################### end of discard only 1 card at a time - place on game action

  #discard = "AS" #change to be user input somehow maybe find a way to see if i can make it so the cards are clickable

  #pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/discard/add/?cards=" + discard

  erb(:game)
end

get("/discard") do
  #i will need to do something with discard parameter i think
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
  discarded_arr = []

  discarded_card = ""

  #check what card(s) were discarded from hand and change hand accordingly
  hand_arr.each do |h|
    if @checked.include?(h)
      discarded_arr.push(h)
    end
  end

  discarded_card = discarded_arr.join(",")

  ## ################# hand pile            maybe i dont need to get the parsed response when im adding cards to piles

  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded_card

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

  ################################## #################  end of discard pile

  ################################################### start of take discarded card and place on discard pile do action if necessary - either suit must match or value must match
  ################################################### end of take discarded card and place on discard pile do action if necessary - either suit must match or value must match

  ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action
  draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=1"
  new_card = api_response(draw, "cards")

  new_card.each do |n|
    @code = n.fetch("code")
  end

  pile_name = "hand"
  add_hand = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code
  resp = HTTP.get(add_hand)

  ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action

  erb(:discard)
end

get("/draw") do
=begin  
  deck = cookies[:deck_id]
  draw = "https://deckofcardsapi.com/api/deck/" + deck +  "/draw/?count=1"
  new_card = api_response(draw, "cards")

  new_card.each do |n|

    @code = n.fetch("code")
  end

  pile_name = "hand"
add_hand = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code
resp = HTTP.get(add_hand)
=end

  ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action
  deck = cookies[:deck_id]

  pile_name = "hand"
  @did_draw = params.fetch("draw")

  #next_draw = params.fetch("draw")
  count = cookies[:count].to_i

  @add_card = cookies[:add_card]
  #make sure only gets called once
  count += 1

  #make sure cookies gets updated
  cookies[:count] = count


  @begin = @add_card

  @is_next = @did_draw == "next_draw" && @add_card = true

  if @did_draw == "next_draw" && @add_card == true

    @draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=1"
    @new_card = api_response(@draw, "cards")

    @new_card.each do |n|
      @code = n.fetch("code")
    end

    pile_name = "hand"
    add_hand = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code
    resp = HTTP.get(add_hand)

    #card was added
    @add_card = false

    @in_next_draw = @add_card
  else
    @in_else = true
  end

  cookies[:add_card] = false

  hand_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @hand = api_response(hand_list, "piles").fetch(pile_name).fetch("cards")

  @image = []
  
  @hand.each do |h|
    @image.push(h.fetch("image"))
  
  end



################################################### end of making draw work

################################################### start of disabled logic

pile_name = "discard"

discard_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

@discard_res = api_response(discard_list, "piles").fetch(pile_name).fetch("cards")

#get last added card which would be on top of discard pile
@discard_arr = []

@discard_res.each_with_index do |d, i|
@in = i
@dlen = @discard_res.length
  if i == @discard_res.length - 1
@top_discard = d
end

@discard_arr.push(d.fetch("image"))

end
#@top_discard.class
#make it so the cards that do not match the most recent card are disabled

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []
  #has code for cards in hand
  @hand.each_with_index do |c, i|

    #this code should still work with this project I think i just need to change the whole thing from checkboxes to radio buttons bc i only need to choose one
    if !(c.fetch("value") == @top_discard["value"] || c.fetch("suit") == @top_discard["suit"] || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
      @disabled_arr.push(c)
    end

    if @disabled_arr.include?(c)
      @disable.push(true)
    else
      @disable.push(false)
    end

  end

  erb(:draw)
end
