require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

require "sinatra/contrib"

# idk if i should go and replace the code with this function now or later ill find out i guess
def api_response(url, key)
  resp = HTTP.get(url)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  #so i dont have to basically make a variable the same as parsed response on line 33 (2 lines above here)
  return fetched_key = parsed_response.fetch(key)
end

#def start()
#each time go back to this page the cards change maybe have to fix  maybe just move all the start game code outside of this action
# ***********************************new deck will be made from 52 cards + extra aces and kings*********************************************************************************
#   new_deck = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"

#   resp = HTTP.get(new_deck)

#   raw_response = resp.to_s

#   parsed_response = JSON.parse(raw_response)

# deck = parsed_response.fetch("deck_id")

#    draw_52 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=52"
# cards = api_response(draw_52, "cards")
# deck_extra = []

# cards.each do |c|
#   deck_extra.push(c.fetch("code"))
# end

# cards_extra_ak = deck_extra.join(",")

# extra_ak = ",AC,AD,AH,AS,KH,KC,KD,KS"

# cards_extra_ak = cards_extra_ak + extra_ak

#  new_deck = "https://deckofcardsapi.com/api/deck/new/shuffle/?cards=" + cards_extra_ak
# return new_deck

# end

def new_deck(url)
  deck = api_response(url, "deck_id")

  return deck

  # DECK_ID = deck
end

# ***********************************new deck will be made from 52 cards + extra aces and kings*********************************************************************************

#get max value from hash
def largest_hash_key(hash)
  hash.max_by { |k, v| v }
end

#draw the extra kings/aces from deck to make the cpu hand work properly
#adds those extras to new pile which will be used to change suits when discarding aces and kings
# def draw_extras(deck, extra_ak)
# #draw the king to be changed from discard pile
#   # draw = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?cards=8"
#   # res = api_response(draw, "cards")[0]
#   # puts "#{res}\n"
#    pile_name = "extras"
#   #need to get all cards so i think i need to do array like usual and push codes to array
   
#   pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + extra_ak#extra_cards
#   res = api_response(pile, "piles")
  
#   pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
#   dr_res = api_response(pile, "piles").fetch(pile_name).fetch("cards")
  
#   c_extra = []
#   dr_res.each do |d|
# c_extra.push(d.fetch("code"))

#     #puts "#{c_extra}\n"
#   end
# end

# def get_deck_api_url(deck, pile, action = 'list', cards = nil)
#   base_url = "https://deckofcardsapi.com/api/deck/#{deck}/pile/#{pile}/"
#   action = cards.nil? ? action : "#{action}/?cards=#{cards}"
#   base_url + action
# end
#usage
#hand_list = get_deck_api_url(deck, 'hand', 'list') seems its only good when i need to add cards idk anything that needs a list of cards

#only goes in game
def cpu()
  deck = cookies[:deck_id]
  puts "deck in cpu() is #{deck}"
  pile_name = "deck"
  cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=7"
  puts "cpu url is #{cpu_url}"
  cpu_cards = api_response(cpu_url, "cards")

  # cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
# cpu_cards = api_response(cpu_url, "piles").fetch(pile_name).fetch("cards")

  @cpu_card_arr = []

  @cpu_code_arr = []
  values = []
  suits = []
  cpu_cards.each do |c|
    @cpu_card_arr.push(c.fetch("image"))

    @cpu_code_arr.push(c.fetch("code"))

    values.push(c.fetch("value"))
    suits.push(c.fetch("suit"))
    # puts "values is #{values}"
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

def cpu_action(value, suit)
 #see if any errors pop up when i just put all the code for cpu discard here *************************************************************
deck = cookies[:deck_id]

  pile_name = "cpu_hand"
  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @cpu_h_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")
  # cpu_cards = cookies[:cpu_cards].split(",")

  #check which cards match what i discarded
  #cpu_hand = cookies[:cpu_hand].split(",")
  cpu_h_codes = []
  cpu_h_vals = []
  cpu_h_suits = []
  @cpu_h_cards.each do |c|
    cpu_h_codes.push(c.fetch("code"))
    cpu_h_vals.push(c.fetch("value"))
    cpu_h_suits.push(c.fetch("suit"))
  end
  deck = cookies[:deck_id]

  values = cookies[:values].split(",")

  suits = cookies[:suits].split(",")

  # if last discarded card was a jack or queen the cpu skips its turn
    if value != "JACK" || value != "QUEEN" || @is_king

  heart_cnt = 0
  dmnd_cnt = 0
  spade_cnt = 0
  club_cnt = 0
  #count how many of each suit there is to determine what to change the king/ace into

  cpu_h_suits.each do |s|
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
     

      if v == heart_cnt
        max_suit = "HEARTS"
      elsif v == dmnd_cnt
        max_suit = "DIAMONDS"
      elsif v == spade_cnt
        max_suit = "SPADES"
      elsif v == club_cnt
        max_suit = "CLUBS"
      else
   #     puts "nothing got done in this v == cnt if"
      end #case
    end #if
  end #each_value
  #puts "max suit in v=l_val if is #{max_suit}"
  #checked is card that was discarded so if i try to match it to this hand that means checked is player 1 discard so cpu has to match it checked has code so
  discarded = ""
  #max_suit = ""
  cant_discard = false
  #has all cards that can be discarded
  cpu_can_discard = []
  cpu_d_val = ""
  cpu_d_suit = ""

  @cpu_h_cards.each_with_index do |h, i|
    if value == h.fetch("value") || suit == h.fetch("suit") || h.fetch("value") == "KING" || h.fetch("value") == "ACE"
      
      discarded = h.fetch("code")
      cpu_can_discard.push(h)
      cpu_d_val = h.fetch("value")
      cpu_d_suit = h.fetch("suit")
    end
  end

  if cpu_can_discard.length == 0
    cant_discard = true
  end

  #if able to discard
  if cant_discard

    pile_name = "deck"
    #draw from deck
    draw_cpu = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

    cpu_draw = api_response(draw_cpu, "cards")

    drawn_cpu_card = ""
    drawn_cpu_value = ""
    drawn_cpu_suit = ""
    cpu_draw.each do |c|
      drawn_cpu_card = c.fetch("code")
      drawn_cpu_value = c.fetch("value")
      drawn_cpu_suit = c.fetch("suit")
    end
    #puts "drawn cpu card is: #{drawn_cpu_card}"

    pile_name = "cpu_hand"
    #add to cpu_hand
    pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + drawn_cpu_card
    s = api_response(pile, "piles").fetch(pile_name)

    @text.push("\n\nBot draws #{drawn_cpu_value} of #{drawn_cpu_suit}")
  else # if able to discard check aces, kings and out side of that discard the card
    #discard card maybe need to put in beginning or osmehting

    #add logic to change king and ace to max suit that means ill have to keep drawing from deck until i find the right one
    #var to hold discarded king
    dis_c_king = ""
    king_cnt = 0
    ace_cnt = 0
    if discarded == "KC" || discarded == "KH" || discarded == "KD" || discarded == "KS"
      case max_suit
      when "HEARTS"
        dis_c_king = "KH"
      when "DIAMONDS"
        dis_c_king = "KD"
      when "SPADES"
        dis_c_king = "KS"
      when "CLUBS"
        dis_c_king = "KC"
      end
      puts "max suit in king if is #{max_suit}"

      king_cnt += 1

      #discard discarded from cpu hand in order to return from deck
      pile_name = "cpu_hand"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
      res = HTTP.get(pile)

# return king from cpu hand to deck that way won't be drawing infinite kings and aces nah i need a counter for kings and aces that way ill only return those cards to the deck once enough have been used
         #return king to deck only if no more using them
         if king_cnt == 4
      return_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/return/?cards=" + discarded

      kdc = api_response(return_dc, "cards")[0]
         
         else
          # add discarded back to deck pile to use again
          pile_name = "deck"
            deck_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded

      kdc = api_response(deck_dc, "success")
    

    pile_name = "deck"
      #draw new king in order to change king suit to max_suit
      king_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + dis_c_king

      kdc = api_response(king_dc, "cards")[0]
      kdc_val = kdc.fetch("value")
      kdc_suit = kdc.fetch("suit")

      #add discarded king that is new to discard
      pile_name = "discard"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + dis_c_king
      res = HTTP.get(pile)
      
      @text.push("\n\nBot discards #{kdc_val} of #{kdc_suit}")

      
      end
  
    elsif discarded == "AC" || discarded == "AH" || discarded == "AD" || discarded == "AS"
      case max_suit
      when "HEARTS"
        dis_c_ace = "AH"
      when "DIAMONDS"
        dis_c_ace = "AD"
      when "SPADES"
        dis_c_ace = "AS"
      when "CLUBS"
        dis_c_ace = "AC"
      end

      ace_cnt += 1

      if ace_cnt == 4
 return_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/return/?cards=" + discarded

      adc = api_response(return_dc, "cards")[0]

      else
      puts "max suit in ace if is #{max_suit}"
      pile_name = "deck"
      draw_4 = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=4"
      draw_4_cards = api_response(draw_4, "cards")
      

      d4 = []
      draw_4_cards.each do |d|
        d4.push(d.fetch("code"))
      end
      d4_cards = d4.join(",")

      pile_name = "hand"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + d4_cards
      api_response(pile, "piles")

    

      pile_name = "discard"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + dis_c_ace
      res = HTTP.get(pile)
      #makes it so that bot can discard an ace and change it to the suit it has the most cards for

      # else # discarded card was not a king or ace and that means dont have to do anything special so only have to add discarded

      #   # add the discarded card to discard pile
      #   pile_name = "discard"
      #   @cd_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
      #   #res = HTTP.get(pile)
      #   d_cpu_res = api_response(@cd_pile, "piles") #.fetch(pile_name).fetch("cards")
       @text.push("\n\nBot discards #{adc_val} of #{adc_suit}")
      # end
    end
    end #if statement for aces

    #in else for cant discard so that means able to discard here

    # draw the card from the cpu hand
  pile_name = "cpu_hand"
  @ch_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
  #res = HTTP.get(pile)
  re = api_response(@ch_pile, "cards")

  pile_name = "discard"
  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
  res = HTTP.get(pile)

  @text.push("\n\nBot discards #{cpu_d_val} of #{cpu_d_suit}")
  end #if for can't discard

  

  pile_name = "cpu_hand"
  @chl_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @new_cards = api_response(@chl_pile, "piles").fetch(pile_name).fetch("cards")

  #return new_cards

  #for some reason having just the methods here messes up later code for getting the hand pile discard_res

  # end # if with jack/queen

  @new_images = []
  @new_cards.each do |n|
    @new_images.push(n.fetch("image"))
  end
end
  end
 
get("/") do
  erb(:home)
end

get("/game") do
  new_deck = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"

  resp = HTTP.get(new_deck)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  deck = parsed_response.fetch("deck_id")

  draw_52 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=52"
  ft_cards = api_response(draw_52, "cards")
  deck_extra = []

  ft_cards.each do |c|
    deck_extra.push(c.fetch("code"))
  end

  cards_deck_pile = deck_extra.join(",")


  # deck = api_response(new_deck, "deck_id")

  # #draw 52 from the new deck with extra kings and aces
  # draw_52 = "https://deckofcardsapi.com/api/deck/" + deck + "/draw/?count=60"
  # cards = api_response(draw_52, "cards")
  # puts "deck in game is #{deck}"
  # url = start()
  # deck = new_deck(url)

  #cookies[:deck_id] = DECK_ID
  #deck = cookies[:deck_id]
  cookies[:deck_id] = deck

  #add the 52 cards from the deck
pile_name = "deck"

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cards_deck_pile
  deck_pile = api_response(pile, "piles")
#   puts "deck pile is #{deck_pile}"
# extra = "AC,AD,AH,AS,KH,KC,KD,KS"
# draw_extras(deck, extra )
  #draw_extras(deck, "KING")
 # draw_extras(deck, "ACE")

  #at this point extra kings will have been drawn from deck so add to new pile extra
  #so do same for aces first check if that other code works

  #see if drawing extra aces and kings fixes issues of bot hand not having kings and aces
  # pile_name = "extras"
  # extra_cards = "AS,AC,AH,AD,KS,KC,KH,KD"
  # pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + extra_cards

  #***********************************************************end of extra kings aces logic
  #start game by drawing 7 cards
  pile_name = "deck"
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name +  "/draw/?count=7"
  re = api_response(start_game, "cards")

#   start_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
# resp = HTTP.get(start_list)

  # raw_response = resp.to_s

  # parsed_response = JSON.parse(raw_response)

  cards = re

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

  rea = api_response(@pile, "success")
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
pile_name = "deck"
  @game_start = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

  #need to get first card
  # game_card = api_response(@game_start, "success")
  
  # @game_starting_draw = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  #need to get first card
  @first_card = api_response(@game_start, "cards")[0]
puts "@first card: #{@first_card}"
  #@first_card.each do |c|
     @card = @first_card.fetch("image")

    @code = @first_card.fetch("code")

     @value = @first_card.fetch("value")

    @suit = @first_card.fetch("suit")
  # end

  # need to add to discard pile
  pile_name = "discard"

  first_discard = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @code

  #adds first card to discard pile
api_response(first_discard, "success")
  # need to add to pile
#   pile_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
#  api_response(pile_list, "success")
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

  @text = []
  @text.push("You discarded the #{discarded_value} of #{discarded_suit}")

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
  # cpu_action(discarded_value, discarded_suit)
  
  #************************************************************************************************************************************





  pile_name = "discard"

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

  ########################################## start of cpu logic
@text = []
  @text.push("You drew a card") #iscarded the #{discarded_value} of #{discarded_suit}")
	 
  # cpu_action(@top_discard.fetch("value"), @top_discard.fetch("suit"))

########################################## end of cpu logic
  

  erb(:draw)
end
