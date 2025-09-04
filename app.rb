require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "rack/contrib/json_body_parser"
require "sinatra/contrib"

use Rack::JSONBodyParser

# idk if i should go and replace the code with this function now or later ill find out i guess
def api_response(url, key)
  resp = HTTP.get(url)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  #so i dont have to basically make a variable the same as parsed response on line 33 (2 lines above here)
  return fetched_key = parsed_response.fetch(key)
end

#get max value from hash
def largest_hash_key(hash)
  hash.max_by { |k, v| v }
end

#only goes in game

def cpu()

  deck = cookies[:deck_id]

 cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=7"

  cpu_cards = api_response(cpu_url, "cards")

  @cpu_card_arr = []

  @cpu_code_arr = []
  values = []
  suits = []
  cpu_cards.each do |c|
    @cpu_card_arr.push(c.fetch("image"))

    @cpu_code_arr.push(c.fetch("code"))

    values.push(c.fetch("value"))
    suits.push(c.fetch("suit"))
  end

  cookies[:cpu_card] = (@cpu_card_arr.join(","))

  cookies[:cpu_code] = @cpu_code_arr.join(",")
  cookies[:values] = (values.join(","))
  cookies[:suits] = (suits.join(","))

  cpu_hand = @cpu_code_arr.join(",")
  pile_name = "cpu_hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @c_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cpu_hand

  resp = HTTP.get(@c_pile)

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  cards_res = api_response(pile, "piles").fetch(pile_name).fetch("cards")

  @c_image = []
  cards_res.each do |c|
    @c_image.push(c.fetch("image"))
  end
  ################################################### end of making cpu hand
#  return cards_res
  
end

####################################################################################################################
=begin 
def cpu_discard(value, suit)
  cpu_cards = cookies[:cpu_cards].split(",")

  #check which cards match what i discarded
  cpu_hand = cookies[:cpu_hand].split(",")

  deck = cookies[:deck_id]

  values = cookies[:values].split(",")

  suits = cookies[:suits].split(",")

  # if last discarded card was a jack or queen the cpu skips its turn
  if value != "JACK" || value != "QUEEN"

    heart_cnt = 0 
    dmnd_cnt = 0 
    spade_cnt = 0 
    club_cnt = 0
    #count how many of each suit there is to determine what to change the king/ace into

    suits.each do |s|
      case s
      when "HEARTS"
        heart_cnt += 1
      when "DIAMONDS"
        dmnd_cnt += 1
      when "SPADES"
        spade_cnt += 1
      when "CLUBS"
        club_cnt += 1
      end
    end

    suit_hash = { :hearts => heart_cnt, :diamonds => dmnd_cnt, :spades => spade_cnt, :clubs => club_cnt }
    

    largest = largest_hash_key(suit_hash)
    l_val = largest[1]

    max_suit = ""
    suit_hash.each_value do |v|

      
      #if value in suit hash is equal to the max value of all the counters
      if v == l_val

        #find out which suit it is
        case v
        when v == heart_cnt
          max_suit = "HEARTS"
        when v == dmnd_cnt
          max_suit = "DIAMONDS"
        when v == spade_cnt
          max_suit = "SPADES"
        when v == club_cnt
          max_suit = "CLUBS"
        end #case
      end #if
    end #each_value

      #checked is card that was discarded so if i try to match it to this hand that means checked is player 1 discard so cpu has to match it checked has code so
     discarded = ""
     #max_suit = ""
      cpu_hand.each_with_index do |h, i|
        if value == values[i] || suit == suits[i] || values[i] == "KING" || values[i] == "ACE"
        #cookies[:cpu_len] = cpu_hand.length
        #cookies[:suits_len] = suits.length
        discarded = h
        end
      end

      if discarded == "KC" || discarded == "KH" || discarded == "KD" || discarded == "KS"
        case max_suit
        when "HEARTS"
          discarded = "KH"
        when "DIAMONDS"
          discarded = "KD"
        when "SPADES"
          discarded = "KS"
        when "CLUBS"
          discarded = "KC"
        end
      
      elsif discarded == "AC" || discarded == "AH" || discarded == "AD" || discarded == "AS"
        case max_suit
        when "HEARTS"
          discarded = "AH"
        when "DIAMONDS"
          discarded = "AD"
        when "SPADES"
          discarded = "AS"
        when "CLUBS"
          discarded = "AC"
        end

        draw_4 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=4"
        draw_4_cards = api_response(draw_4, "cards")
        pile_name = "hand"

        d4 = []
        draw_4_cards.each do |d|
          d4.push(d.fetch("code"))
        end
        d4_cards = d4.join(",")
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + d4_cards
        res = HTTP.get(pile)

      end #if statement for aces

    

      # draw the card from the cpu hand
      pile_name = "cpu_hand"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
      res = HTTP.get(pile)

      # add the discarded card to discard pile
      pile_name = "discard"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
      res = HTTP.get(pile)

      pile_name = "cpu_hand"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
      new_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")

      @new_images = []
      new_cards.each do |n|
        @new_images.push(n.fetch("image"))
      end

      
      #return new_cards

      #for some reason having just the methods here messes up later code for getting the hand pile discard_res
    
    
    end # if with jack/queen
  

  end
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

  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cookies[:hand]

  resp = HTTP.get(@pile)
################################################### start of cpu cards
  #start game by drawing 7 cards
=begin
  cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=7"

  cpu_cards = api_response(cpu_url, "cards")

  @cpu_card_arr = []

  @cpu_code_arr = []
  values = []
  suits = []
  cpu_cards.each do |c|
    @cpu_card_arr.push(c.fetch("image"))

    @cpu_code_arr.push(c.fetch("code"))

    values.push(c.fetch("value"))
    suits.push(c.fetch("suit"))
  end

  cookies[:cpu_card] = (@cpu_card_arr.join(","))

  cookies[:cpu_code] = @cpu_code_arr.join(",")
  cookies[:values] = (values.join(","))
  cookies[:suits] = (suits.join(","))

  cpu_hand = @cpu_code_arr.join(",")
  pile_name = "cpu_hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @c_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cpu_hand

  resp = HTTP.get(@c_pile)

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @cards_res = api_response(pile, "piles").fetch(pile_name).fetch("cards")
=end
cpu()  
  #cpu hand
  #cpu_hand_arr = cpu(cpu_cards)

  ################################################### end of cpu cards

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

  @disable_button = false
  if c == d
    @disable_button = true
  end
  #maybe this part needs to be in draw action
  #how to make this true when button is pressed
  #only draw when all cards are disabled actually might need to do something else here like if draw exists in params idk
=begin
if c == d

  ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action
  draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=1"
  new_card = api_response(draw, "cards")

  new_card.each do |n|
    @code = n.fetch("code")
  end

  pile_name = "hand"
  add_hand = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code
  resp = HTTP.get(add_hand)

=end
  ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action

  ################################################### end of take top card from deck and place on discard pile which starts the game - place on game action

  ################################################### start of discard only 1 card at a time - place on game action
  ################################################### end of discard only 1 card at a time - place on game action

  #discard = "AS" #change to be user input somehow maybe find a way to see if i can make it so the cards are clickable

  #pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/discard/add/?cards=" + discard

  erb(:game)
end

get("/discard") do

  #card to be discarded
  @discard = params.key("on")
    

  deck = cookies[:deck_id]

=begin
  #array of the cards in hand
  hand_arr = cookies[:hand].split(",")

  #string of hand cards
  hand = cookies[:hand]

=end
  pile_name = "hand"
  hand_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @hand = api_response(hand_list, "piles").fetch(pile_name).fetch("cards")

  discarded_arr = []

  @discarded_card = ""

  #check what card(s) were discarded from hand and change hand accordingly
  @hand.each do |h|
    if h == @discard
      discarded_arr.push(h)
    end
  end

  @curr_hand = []
  @hand.each do |h|
    @curr_hand.push(h.fetch("code"))
  end
  @discarded_card = discarded_arr.join(",")

  ## ################# hand pile            maybe i dont need to get the parsed response when im adding cards to piles

  pile_name = "hand"

 

  #draw from the pile which would be discarding in this case
  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard

  d_res = api_response(pile, "cards")

  discarded_value = ""
  discarded_suit = ""
  d_res.each do |d|
    discarded_value = d.fetch("value")
    discarded_suit = d.fetch("suit")
  end

 
pile_name = "hand"  

#this gives back new hand
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

 #not sure where to put this
   #cpu_discard(discarded_value, discarded_suit)
#see if any errors pop up when i just put all the code for cpu discard here *************************************************************

pile_name = "cpu_hand"
pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
@cpu_h_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")
 cpu_cards = cookies[:cpu_cards].split(",")

  #check which cards match what i discarded
  #cpu_hand = cookies[:cpu_hand].split(",")
cpu_h_codes = []
 # @cpu_h_cards.each do |c|
  #  cpu_h_codes.push(c.fetch("code"))
#end
  deck = cookies[:deck_id]

  values = cookies[:values].split(",")

  suits = cookies[:suits].split(",")

  # if last discarded card was a jack or queen the cpu skips its turn
#  if discarded_value != "JACK" || discarded_value != "QUEEN"

    heart_cnt = 0 
    dmnd_cnt = 0 
    spade_cnt = 0 
    club_cnt = 0
    #count how many of each suit there is to determine what to change the king/ace into

    suits.each do |s|
      case s
      when "HEARTS"
        heart_cnt += 1
      when "DIAMONDS"
        dmnd_cnt += 1
      when "SPADES"
        spade_cnt += 1
      when "CLUBS"
        club_cnt += 1
      end
    end

    suit_hash = { :hearts => heart_cnt, :diamonds => dmnd_cnt, :spades => spade_cnt, :clubs => club_cnt }
    

    largest = largest_hash_key(suit_hash)
    l_val = largest[1]

    max_suit = ""
    suit_hash.each_value do |v|

      
      #if value in suit hash is equal to the max value of all the counters
      if v == l_val

        #find out which suit it is
        case v
        when v == heart_cnt
          max_suit = "HEARTS"
        when v == dmnd_cnt
          max_suit = "DIAMONDS"
        when v == spade_cnt
          max_suit = "SPADES"
        when v == club_cnt
          max_suit = "CLUBS"
        end #case
      end #if
    end #each_value

      #checked is card that was discarded so if i try to match it to this hand that means checked is player 1 discard so cpu has to match it checked has code so
     discarded = ""
     #max_suit = ""
      @cpu_h_cards.each_with_index do |h, i|
        if discarded_value == values[i] || discarded_suit == suits[i] || values[i] == "KING" || values[i] == "ACE"
        #cookies[:cpu_len] = cpu_hand.length
        #cookies[:suits_len] = suits.length
        discarded = h.fetch("code")
        end
      end
=begin
      if discarded == "KC" || discarded == "KH" || discarded == "KD" || discarded == "KS"
        case max_suit
        when "HEARTS"
          discarded = "KH"
        when "DIAMONDS"
          discarded = "KD"
        when "SPADES"
          discarded = "KS"
        when "CLUBS"
          discarded = "KC"
        end
      
      elsif discarded == "AC" || discarded == "AH" || discarded == "AD" || discarded == "AS"
        case max_suit
        when "HEARTS"
          discarded = "AH"
        when "DIAMONDS"
          discarded = "AD"
        when "SPADES"
          discarded = "AS"
        when "CLUBS"
          discarded = "AC"
        end

        draw_4 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=4"
        draw_4_cards = api_response(draw_4, "cards")
        pile_name = "hand"

        d4 = []
        draw_4_cards.each do |d|
          d4.push(d.fetch("code"))
        end
        d4_cards = d4.join(",")
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + d4_cards
        res = HTTP.get(pile)

      end #if statement for aces

=end

      # draw the card from the cpu hand
      pile_name = "cpu_hand"
      @ch_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
      #res = HTTP.get(pile)
      re = api_response(@ch_pile, "cards")

      puts "this is re: #{re}"  
      # add the discarded card to discard pile
      pile_name = "discard"
      @cd_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
      res = HTTP.get(pile)

      pile_name = "cpu_hand"
      @chl_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
      @new_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")

      #puts "this is @new_cards: #{@new_cards}"  

      #return new_cards

      #for some reason having just the methods here messes up later code for getting the hand pile discard_res
 
    
   # end # if with jack/queen
  

  @new_images = []
      @new_cards.each do |n|
        @new_images.push(n.fetch("image"))
      end


#************************************************************************************************************************************







  pile_name="discard"


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

  ################################################### start of disabled logic
  #pile name is currently discard
  #pile_name = "discard"

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

  cookies[:top_code] = @top_discard.fetch("code")
  #cookies[:top_value] = @top_discard.fetch("value")
  #cookies[:top_suit] = @top_discard.fetch("suit")
  #@top_discard.class
  #make it so the cards that do not match the most recent card are disabled

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []
  #has code for cards in hand
  @cards.each_with_index do |c, i|

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

  c = @cards.join(",")
  d = @disabled_arr.join(",")

  cookies[:disable] = @disable.join(",")

  ######################################### end of disabled logic

  ################################################### start of take discarded card and place on discard pile do action if necessary - either suit must match or value must match
  ################################################### end of take discarded card and place on discard pile do action if necessary - either suit must match or value must match

  ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action maybe dont need bc i disable cards
  @disable_button = false
  if c == d
    @disable_button = true
  end
  ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action
  @is_king = false
  if @top_discard.fetch("value") == "KING"
    @is_king = true
  end

  new_deck = "https://deckofcardsapi.com/api/deck/new/?cards=KS,KC,KH,KD"

  @deck = api_response(new_deck, "deck_id")
  cookies[:king_deck] = @deck

  king_draw = "https://deckofcardsapi.com/api/deck/" + @deck + "/draw/?count=4"

  @cards_to_add = api_response(king_draw, "cards")

  king_add = []
  @cards_to_add.each do |c|
    king_add.push(c.fetch("code"))
  end
  pile_name = "kings"

  cards = king_add.join(",")

  #might need to change to add cards from partial deck
  pile = "https://deckofcardsapi.com/api/deck/" + @deck + "/pile/" + pile_name + "/add/?cards=" + cards
  resp = HTTP.get(pile)

  pile_list = "https://deckofcardsapi.com/api/deck/" + @deck + "/pile/" + pile_name + "/list/"

  @kings = api_response(pile_list, "piles").fetch("kings").fetch("cards")

  @king_arr = []
  @king_codes = []
  @kings.each do |c|
    @king_arr.push(c.fetch("image"))

    @king_codes.push(c.fetch("code"))
  end

  
  erb(:discard)
end

#having to different decks might not be working so will have to draw from current deck until we reach the requested king card if its not a king card return it to the deck

get("/discard/king") do
  deck = cookies[:deck_id]

  pile_name = "hand"

  pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  @cards = api_response(pile_list, "piles").fetch("hand").fetch("cards")

  #@cards = @parsed_response.fetch("piles").fetch("hand").fetch("cards")

  @hand_arr = []

  @hand_code = []
  @cards.each do |c|
    @hand_arr.push(c.fetch("image"))

    @hand_code.push(c.fetch("code"))
  end

  @disable = cookies[:disable].split(",")
  ################################################### start of change suit with king
  #get the suits to pop up after placing king choosing one changes the king on the discard pile
  #new partial deck

  #king"code"=on will be parameter so use it to change king in discard pile to that one
  #make sure king works fine
  @in_king = false

  king = params.fetch("king")
  @in_king = true

  #@king_codes.each do |k|
  # if k == king

  #king = key.split("_")

  #king code in discard pile
  #king[1]

  #i think i will need to put all king logic in new view so maybe check if king was discarded and make button redirect to view king and then cpu would discard a card and then you get to discard so after king got changed you would get redirected to discard
  pile_name = "discard"

  @top_code = cookies[:top_code]

  #draw the king to be changed from discard pile
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @top_code

  resp = HTTP.get(@pile)
  #may or may not have to add that discarded card back to deck somehow
  return_url = "https://deckofcardsapi.com/api/deck/" + deck + "/return/?cards=" + @top_code
  resp = HTTP.get(return_url)

  pile_name = "kings"
  @king_deck = cookies[:king_deck]

  #draw requsted king
  # king_pile = "https://deckofcardsapi.com/api/deck/" + @king_deck + "/pile/" + pile_name + "/draw/?cards=" + king
  # resp = HTTP.get(king_pile)

  #need to find way to draw card from a pile and add it to the right piles
  #drawing from deck does not draw specific card from deck

  king_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?cards=1"
  drawn_card = api_response(king_pile, "cards")[0].fetch("code")
  while (drawn_card != king)
    return_url = "https://deckofcardsapi.com/api/deck/" + deck + "/return/?cards=" + drawn_card
    resp = HTTP.get(return_url)
    king_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?cards=1"
    drawn_card = api_response(king_pile, "cards")[0].fetch("code")
  end

  #resp = HTTP.get(king_pile)
  #add requested king to discard pile
  #maybe i need to draw requested king from deck and to pile
  pile_name = "discard"
  @new_king = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + king
  resp = HTTP.get(@new_king)

  pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  @discards = api_response(pile_list, "piles").fetch(pile_name).fetch("cards")
  #add the pile list here

  @new_king_arr = []
  @new_king_codes = []
  # then use it to display new pile
  @discards.each do |c|
    @new_king_arr.push(c.fetch("image"))
    @new_king_codes.push(c.fetch("code"))
  end

  ################################################### end of change suit with king

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

  #update disable logic for hand here
  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []
  #has code for cards in hand
  @cards.each_with_index do |c, i|

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

  c = @cards.join(",")
  d = @disabled_arr.join(",")

  erb(:discard_king)
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
  @code_arr = []
  @hand.each do |h|
    @image.push(h.fetch("image"))
    @code_arr.push(h.fetch("code"))
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

  c = @hand.join(",")
  d = @disabled_arr.join(",")

  @disable_button = false
  if c == d
    @disable_button = true
  end

  ######################################### end of disabled logic

  ########################################## start of discard logic

  #need to add way for hand to be updated i think

  erb(:draw)
end
