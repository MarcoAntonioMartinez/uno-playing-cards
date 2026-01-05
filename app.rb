require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "sinatra/contrib"
require "uri"
require_relative "hand"

# handles api requests
def api_response(url, key)
  resp = HTTP.get(url)

  raw_response = resp.to_s

  parsed_response = JSON.parse(raw_response)

  #so i dont have to basically make a variable the same as parsed response on line 33 (2 lines above here)
  return fetched_key = parsed_response.fetch(key)
end

def new_deck(url)
  deck = api_response(url, "deck_id")

  return deck

  # DECK_ID = deck
end

#get max value from hash
def largest_hash_key(hash)
  hash.max_by { |k, v| v }
end

# make it so when discard button is pressed, random able card is discarded or at least chosen
def discard(arr, disc_arr)
  h_arr = []
  rand_index = 0
@can_rand_discard = true

  # h_arr has all cards from arr that are able to be discarded
  h_arr = arr.select { |h| !disc_arr.include?(h) }

  if h_arr == nil
    puts "arr and disc_arr are equal no card can be discarded"
    @can_rand_discard = false
  else
  rand_index = rand(0..h_arr.length - 1)
  end
  # return h_arr[rand_index] # so i think i either need to put this whole function after the if statement for discarding as part of the else statement or something and @hand array will have to be an array which takes from whatever array is being worked on in if ace king statement
  # h_arr is image which would be randomly chosen so add to discard pile

  # end
  # if @hand_arr != nil
  return h_arr[rand_index]
end

#only goes in game
def cpu()
  deck = cookies[:deck_id]
  # puts "deck in cpu() is #{deck}"
  pile_name = "deck"
  cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=7"
  # puts "cpu url is #{cpu_url}"
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

  cookies[:cpu_cards] = (@cpu_card_arr.join(","))

  cookies[:cpu_codes] = @cpu_code_arr.join(",")
  cookies[:cpu_values] = (values.join(","))
  cookies[:cpu_suits] = (suits.join(","))

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

  cookies[:cpu_turns] = 0

  session[:player_turn] = true
end

####################################################################################################################

def cpu_action(value, suit)
  deck = cookies[:deck_id]

  pile_name = "cpu_hand"
  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @cpu_h_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")

  cpu_h_codes = []

  # used to determine if player lost when cpu hand has no cards
  @cpu_empty = false

  values = []
  suits = []

  @cpu_h_cards.each do |c|
    cpu_h_codes.push(c.fetch("code"))
    values.push(c.fetch("value"))
    suits.push(c.fetch("suit"))
  end
  deck = cookies[:deck_id]

  #variable true if cpu has discarded all necessary cards
  has_discarded = false

  # try to make it so jack and queen only affects the cpu once; like i discard jack and my second action would be to draw cpu should then take its turn
  jq_cnt = 0

  session[:jack_used] = false
  session[:queen_used] = false

  k_arr = cookies[:king_arr].split(",")
  a_arr = cookies[:ace_arr].split(",")

  spade_indx = 0
  clubs_indx = 1
  diamond_indx = 2
  heart_indx = 3

  @cpu_discarded = true

  cpu_turns = cookies[:cpu_turns].to_i

  if cpu_turns == 3
    session[:player_turn] = true
  end

  # puts session[:player_turn].class

  return if cpu_turns > 3

  # if last discarded card was a jack or queen the cpu skips its turn
  if ((value == "JACK" || value == "QUEEN") && session[:player_turn] == true)

    # @text.push("Player discarded a #{value}, skipping the CPU's turn.")

    jq_cnt += 1
  else
    heart_cnt = 0
    dmnd_cnt = 0
    spade_cnt = 0
    club_cnt = 0

    session[:jack_used] = false
    session[:queen_used] = false

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
        if v == heart_cnt
          max_suit = "HEARTS"
        elsif v == dmnd_cnt
          max_suit = "DIAMONDS"
        elsif v == spade_cnt
          max_suit = "SPADES"
        elsif v == club_cnt
          max_suit = "CLUBS"
        else
        end #case
      end #if
    end #each_value

    #checked is card that was discarded so if i try to match it to this hand that means checked is player 1 discard so cpu has to match it checked has code so
    discarded = ""

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

    cookies[:cpu_val] = cpu_d_val
    cookies[:cpu_suit] = cpu_d_suit

    if cpu_can_discard.length == 0
      cant_discard = true
    end

    # make array for discard pile
    # discard_pile = cookies[:discard_pile].split(",")
    @discard_pile ||= cookies[:discard_pile]&.split(",") || []
    #if not able to discard
    if cant_discard
      pile_name = "deck"
      #draw from deck
      draw_cpu = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

      cpu_draw = api_response(draw_cpu, "cards")[0]

      drawn_cpu_card = cpu_draw.fetch("code")
      drawn_cpu_value = cpu_draw.fetch("value")
      drawn_cpu_suit = cpu_draw.fetch("suit")

      @dis_val = cookies[:disc_val]
      @dis_suit = cookies[:disc_suit]

      pile_name = "cpu_hand"
      #add to cpu_hand
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + drawn_cpu_card
      s = api_response(pile, "piles").fetch(pile_name)

      # to prevent card from being discarded if cpu has drawn a card
      # has_discarded = true

      @text.push("\n\nCPU draws #{drawn_cpu_value} of #{drawn_cpu_suit}")
    else # if able to discard check aces, kings and out side of that discard the card
      #discard card maybe need to put in beginning or osmehting

      #add logic to change king and ace to max suit that means ill have to keep drawing from deck until i find the right one
      #var to hold discarded king
      dis_c_king = ""
      king_img = ""
      if discarded == "KC" || discarded == "KH" || discarded == "KD" || discarded == "KS"
        dis_king_val = "KING"
        case max_suit
        when "HEARTS"
          dis_c_king = "KH"

          dis_king_suit = "HEARTS"
          king_img = k_arr[heart_indx]
        when "DIAMONDS"
          dis_c_king = "KD"

          dis_king_suit = "DIAMONDS"
          king_img = k_arr[diamond_indx]
        when "SPADES"
          dis_c_king = "KS"

          dis_king_suit = "SPADES"
          king_img = k_arr[spade_indx]
        when "CLUBS"
          dis_c_king = "KC"

          dis_king_suit = "CLUBS"
          king_img = k_arr[clubs_indx]
        end
        puts "max suit in king if is #{max_suit}"

        #discard discarded from cpu hand in order to return from deck
        pile_name = "cpu_hand"
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
        res = HTTP.get(pile)

        #update cpu_hand

        #set to true because now discarded cant be drawn again
        # has_discarded = true

        has_discarded = true

        @discard_pile.push(king_img)

        cookies[:disc_val] = dis_king_val
        cookies[:disc_suit] = dis_king_suit

        @text.push("\n\nCPU discards #{dis_king_val} of #{dis_king_suit}")
        #only add session:text to text if action is not draw for player

      elsif discarded == "AC" || discarded == "AH" || discarded == "AD" || discarded == "AS"
        ace_img = []
        dis_ace_val = "ACE"

        case max_suit
        when "HEARTS"
          dis_c_ace = "AH"
          dis_ace_suit = "HEARTS"
          ace_img = a_arr[heart_indx]
        when "DIAMONDS"
          dis_c_ace = "AD"

          dis_ace_suit = "DIAMONDS"
          ace_img = a_arr[diamond_indx]
        when "SPADES"
          dis_c_ace = "AS"
          dis_ace_suit = "SPADES"
          ace_img = a_arr[spade_indx]
        when "CLUBS"
          dis_c_ace = "AC"
          dis_ace_suit = "CLUBS"
          ace_img = a_arr[clubs_indx]
        end

        #update cpu hand
        #discard discarded from cpu hand in order to return from deck
        pile_name = "cpu_hand"
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
        res = HTTP.get(pile)

        has_discarded = true

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

        @discard_pile.push(ace_img)
        cookies[:disc_val] = dis_ace_val
        cookies[:disc_suit] = dis_ace_suit
        @text.push("\n\nCPU discards #{dis_ace_val} of #{dis_ace_suit}")
        # puts "this does twice apparently"
        #ok so maybe i need to do if statment for discard pile pushing like bool variable when king or ace img has been discarded
      end #if statement for aces

      #in else for cant discard so that means able to discard here
      #so whats happening is that i think bc i discarded the card already earlier its trying to discard here
      # draw the card from the cpu hand i guess check why it doesnt work like this i thought it was in else and wouldnt be affected the king or ace discard

      #THIS CODE IS ABSOLUTELY NECESSARY I JUST REALLY NEED TO FIND OUT HOW TO GET IT TO WORK I NEED TO DISCARD THE CARD IF ITS NOT AN ACE AND NOT A KING
      if !has_discarded
        pile_name = "cpu_hand"
        @ch_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
        # res = HTTP.get(@ch_pile)
        discarded_cpu = api_response(@ch_pile, "cards")[0]
        # pile_name = "discard"
        # pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
        # res = HTTP.get(pile)

        #discard by pushing to array
        @discard_pile.push(discarded_cpu.fetch("image"))

        # add value and suit to variables so can be used to properly chose card to discard
        @dis_val = discarded_cpu.fetch("value")
        @dis_suit = discarded_cpu.fetch("suit")

        cookies[:disc_val] = @dis_val
        cookies[:disc_suit] = @dis_suit

        # if session[:text] != nil
        #   if session[:text].is_a?(String)
        @text.push("\n\nCPU discards #{cpu_d_val} of #{cpu_d_suit}")

        # move this to be an elsif after aces
        if cpu_d_val == "JACK" || cpu_d_val == "QUEEN"
          # puts "session before assign" + session[:player_turn].to_s
          session[:player_turn] = false
          # puts "session after assign" + session[:player_turn].to_s
          cpu_turns += 1
          cpu_action(cpu_d_val, cpu_d_suit)
        end
      end # end if to check if card was already discarded from cpu_hand
    end #if for can't discard
  end # end for jack / queen

  # end # if with jack/queen

  # end # if for jac/queen
  session[:jack_used] = false
  session[:queen_used] = false

  pile_name = "cpu_hand"
  @chl_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @new_cards = api_response(@chl_pile, "piles").fetch(pile_name).fetch("cards")

  cookies[:cpu_cards] = @cpu_h_cards.join(",")
  cookies[:cpu_codes] = cpu_h_codes.join(",")
  cookies[:cpu_suits] = suits.join(",")
  cookies[:cpu_values] = values.join(",")

  @new_images = []
  @new_cards.each do |n|
    @new_images.push(n.fetch("image"))
  end #end loop

  if @discard_pile != nil
    cookies[:discard_pile] = @discard_pile.join(",")

    if cpu_d_val == "KING"
      #use cookies cpu_val
      cookies[:last_suit] = dis_king_suit
    elsif cpu_d_val == "ACE"
      #use cookies cpu_val

      cookies[:last_suit] = dis_ace_suit
    end
  end

  if @new_images.length == 1
    @cpu_empty = true
  end

puts "cpu_empty is " + @cpu_empty.to_s
  cookies[:disc_val] = cpu_d_val
  cookies[:disc_suit] = cpu_d_suit
end #end function

get("/") do
  # session.clear
  erb(:home)
end

get("/game") do

  #clear session if it hasnt already been cleared
  #   if session != {}
  #   session.clear
  # end

  # array that has aces in it
  ace_arr = [
    "https://deckofcardsapi.com/static/img/AS.png", "https://deckofcardsapi.com/static/img/AC.png", "https://deckofcardsapi.com/static/img/AD.png", "https://deckofcardsapi.com/static/img/AH.png",
  ]

  # array that has kings in it
  king_arr = ["https://deckofcardsapi.com/static/img/KS.png", "https://deckofcardsapi.com/static/img/KC.png", "https://deckofcardsapi.com/static/img/KD.png", "https://deckofcardsapi.com/static/img/KH.png"]

  cookies[:king_arr] = king_arr.join(",")
  cookies[:ace_arr] = ace_arr.join(",")

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

  cookies[:deck_id] = deck

  #add the 52 cards from the deck
  pile_name = "deck"

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cards_deck_pile
  deck_pile = api_response(pile, "piles")

  #start game by drawing 7 cards
  pile_name = "deck"
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=7"
  re = api_response(start_game, "cards")

  cards = re

  @card_arr = []

  @code_arr = []

  cards.each do |c|
    @card_arr.push(c.fetch("image"))

    @code_arr.push(c.fetch("code"))

    cookies[:hand] = (@code_arr.join(","))
  end

  # send hand array to discard action to be used for choosing random card to discard
  cookies[:random_hand] = @card_arr.join(",")

  pile_name = "hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cookies[:hand]

  rea = api_response(@pile, "success")

  cpu()

  ################################################### start of take top card from deck and place on discard pile which starts the game - place on game action
  pile_name = "deck"
  @game_start = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

  #need to get first card
  @first_card = api_response(@game_start, "cards")[0]
  # puts "@first card: #{@first_card}"
  #@first_card.each do |c|
  @card = @first_card.fetch("image")

  @code = @first_card.fetch("code")

  @value = @first_card.fetch("value")

  @suit = @first_card.fetch("suit")
  # end

  @discard_pile = []

  #add first discard to pile
  @discard_pile.push(@card)

  cookies[:discard_pile] = @discard_pile

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

  ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action

  ################################################### end of take top card from deck and place on discard pile which starts the game - place on game action

  ################################################### start of discard only 1 card at a time - place on game action
  ################################################### end of discard only 1 card at a time - place on game action

  erb(:game)
end

get("/discard") do

  # #add discard pile here
  #  ? @discard_pile = cookies[:discard_pile].split(",")
  @discard_pile = []

  if @discard_pile.length == 0
    arr = cookies[:discard_pile].split(",")

    arr.each do |a|
      if a != @discard_pile.last
        @discard_pile.push(a)
      end
    end
  end

  #if no card was chosen then push random  card to discard pile
  #card to be discarded
  #i forgot to do the push and make it uncommented so do that for next time
  if params.empty? != true
    @discard = params.key("on")
  else
    @random = true
    # @discard_pile.push(discard())
  end

  deck = cookies[:deck_id]

  @is_king = false

  @text = []

  d_res = []

# set variable to be used to determine result for game like win or lose
  @win = false

  #these arrs holds all kings and aces used to check if king or ace cpu is looking for is in player's hand
  k_arr = cookies[:king_arr].split(",")
  a_arr = cookies[:ace_arr].split(",")

  spade_indx = 0
  clubs_indx = 1
  diamond_indx = 2
  heart_indx = 3

  @code_arr = []

  @dis_val = ""
  @dis_suit = ""

  @disabled_arr = []

  # array for holding true false vals for disabled
  @is_disabled = []
  discarded_value = ""
  discarded_suit = ""
  #if to check which king card is being discarded; it would be chosen from button so fetch king
  if !@random
    if params.key?("king")
      # i will most likely have to disable discard when king is selected in hand
      king_p = params.fetch("king")

      case king_p
      when "KS"
        discarded_value = "KING"
        discarded_suit = "SPADES"
        king_img = k_arr[spade_indx]
      when "KC"
        discarded_value = "KING"
        discarded_suit = "CLUBS"
        king_img = k_arr[clubs_indx]
      when "KH"
        discarded_value = "KING"
        discarded_suit = "HEARTS"
        king_img = k_arr[heart_indx]
      when "KD"
        discarded_value = "KING"
        discarded_suit = "DIAMONDS"
        king_img = k_arr[diamond_indx]
      end

      @code_arr.push(king_p)

      pile_name = "hand"
      #need to draw king from hand and do not add to discard just add back to deck pile unless kingcnt = 4 then return to deck then draw new king from deck and that to discard
      king_hd = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard
      api_response(king_hd, "success")

      # and add new king to discard pile
      @discard_pile.push(king_img)
      cookies[:disc_val] = discarded_value
      cookies[:disc_suit] = discarded_suit
    elsif params.key?("ace")
      ace_p = params.fetch("ace")

      case ace_p
      when "AS"
        discarded_value = "ACE"
        discarded_suit = "SPADES"
        ace_img = a_arr[spade_indx]
      when "AC"
        discarded_value = "ACE"
        discarded_suit = "CLUBS"
        ace_img = a_arr[clubs_indx]
      when "AH"
        discarded_value = "ACE"
        discarded_suit = "HEARTS"
        ace_img = a_arr[heart_indx]
      when "AD"
        discarded_value = "ACE"
        discarded_suit = "DIAMONDS"
        ace_img = a_arr[diamond_indx]
      end

      @code_arr.push(ace_p)

      pile_name = "hand"
      #need to draw king from hand and do not add to discard just add back to deck pile unless kingcnt = 4 then return to deck then draw new king from deck and that to discard
      ace_hd = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard
      api_response(ace_hd, "success")

      pile_name = "deck"
      draw_4 = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=4"
      draw_4_cards = api_response(draw_4, "cards")

      d4 = []
      draw_4_cards.each do |d|
        d4.push(d.fetch("code"))
      end
      d4_cards = d4.join(",")

      pile_name = "cpu_hand"
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + d4_cards
      api_response(pile, "piles")

      @discard_pile.push(ace_img)
      cookies[:disc_val] = discarded_value
      cookies[:disc_suit] = discarded_suit
    else # no king value to be discarded so discard normally
      if cookies[:cpu_val] != nil
        cpu_val = cookies[:cpu_val]
      end

      # drwing from hand here
      pile_name = "hand"

      #draw from the pile which would be discarding in this case; this discards chosen card from hand
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard

      d_res = api_response(pile, "cards")

      discarded_img = ""
      discarded_code = ""
      d_res.each do |d|
        discarded_value = d.fetch("value")
        discarded_suit = d.fetch("suit")
        discarded_img = d.fetch("image")
        discarded_code = d.fetch("code")
      end
      #discard

      @discard_pile.push(discarded_img)
      @code_arr.push(discarded_code)
      cookies[:disc_val] = discarded_value
      cookies[:disc_suit] = discarded_suit
    end #end of if for params?

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

    @text.push("You discarded the #{discarded_value} of #{discarded_suit}")

    session[:player_turn] = true

    #save it so can tell if cpu drew a card
    if @new_images != nil
      cpu_length = @new_images.length
    else
      cpu_length = 0
    end
  else # random if

pile_name = "hand"
    hand_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
    @hand = api_response(hand_list, "piles").fetch(pile_name).fetch("cards")


    last_card = @discard_pile.last

    last_code = last_card.gsub(/[A-Z]/, "")

    rand_code = last_code.split("")

    case rand_code[0]
    when "A"
      discarded_value = "ACE"
    when "K"
      discarded_value = "KING"
    else
      discarded_value = rand_code[0]
    end

    case rand_code[1]
    when "H"
      discarded_suit = "HEARTS"
    when "D"
      discarded_suit = "DIAMONDS"
    when "S"
      discarded_suit = "SPADES"
    when "C"
      discarded_suit = "CLUBS"
    end

    top_val = discarded_value
    top_suit = discarded_suit

    @rand_disabled = []

    # push all cards from hand which cant be discarded to @rand_disabled
    @hand.each do |c|
      # check to see what cards would be disabled
      if !(c.fetch("value") == top_val || c.fetch("suit") == top_suit || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
        @rand_disabled.push(c)
      end
    end
    # change disable arr to be arg for discard()
    #discard card from hand
    rand_card = discard(@hand, @rand_disabled)

    rand_code = rand_card.fetch("image").gsub(/[^A-Z]/, "")

    rand_img = rand_card.fetch("image")

    # drwing from hand here
    pile_name = "hand"

    #draw from the pile which would be discarding in this case; this discards chosen card from hand
    pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + rand_code

    puts rand_code
    d_res = api_response(pile, "cards")

    @discard_pile.push(rand_img)

    # disabled stuff
    @r_cards = []
    @hand.each do |c|
      # check to see what cards would be disabled
      if !(c.fetch("value") == top_val || c.fetch("suit") == top_suit || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
        @rand_disabled.push(c)
        @r_cards.push(c.fetch("image"))
      end

      if @rand_disabled.include?(c)
        @is_disabled.push(true)
      else
        @is_disabled.push(false)
      end
    end # hand each

    c = @r_cards.join(",")
    d = @disabled_arr.join(",")

    cookies[:disable] = @is_disabled.join(",")

    @disable_button = false
    if c == d
      @disable_button = true
    end
  end # end for random if

  # rand_hand = cookies[:random_hand].split(",")

  # val = cookies[:]

  #not sure where to put this
  cpu_action(discarded_value, discarded_suit)

  #potential place to put if for queen jack skipping player turn

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

  d = URI.decode_www_form_component(cookies[:discard_pile])
  arr = d.split(",")
  # puts arr.last
  # arr.each do |c|
  #   @discard_pile.push(URI.decode_www_form_component(c))
  # end
  if arr.last != @discard_pile[0] && arr.last != @discard_pile.last
    @discard_pile.push(URI.decode_www_form_component(arr.last))
  end
  @discard_pile.each_with_index do |d, i|
    if i == @discard_pile.length - 1
      @top_discard = d #image need code,value,suit
    end
  end
  #get code from image string
  top_code = @top_discard.gsub(/[A-Z]/, "")

  cookies[:top_code] = top_code

  # if cpu cards well it has to do with when drawing instead of discarding on first turn
  if cpu_length != @new_images.length + 1
    top_val = cookies[:disc_val]
    top_suit = cookies[:disc_suit]
  else # otherwise top_val is what was just discarded bc cpu didnt discard
    top_val = discarded_value
    top_suit = discarded_suit
  end

  #make it so the cards that do not match the most recent card are disabled

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  if !@random
    @disabled_arr = []

    #has code for cards in hand
    @cards.each_with_index do |c, i|

      # if !(c.fetch("value") == @top_discard["value"] || c.fetch("suit") == @top_discard["suit"] || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
      if !(c.fetch("value") == top_val || c.fetch("suit") == top_suit || c.fetch("value") == "KING" || c.fetch("value") == "ACE")
        @disabled_arr.push(c)
      end

      if @disabled_arr.include?(c)
        @is_disabled.push(true)
      else
        @is_disabled.push(false)
      end
    end

    c = @cards.join(",")
    d = @disabled_arr.join(",")

    cookies[:disable] = @is_disabled.join(",")

    # if there is nothing in disabled array and there is only one card in hand
    if @disabled_arr.length == 0 && @hand_arr == 1
      
      # then result will become win
      @win = true
    end

    ######################################### end of disabled logic

    ################################################### start of take discarded card and place on discard pile do action if necessary - either suit must match or value must match
    ################################################### end of take discarded card and place on discard pile do action if necessary - either suit must match or value must match

    ################################################### start of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action maybe dont need bc i disable cards
    @disable_button = false
    if c == d
      @disable_button = true
    end
    ################################################### end of check if any card in hand matches discard pile if none then draw card and next player takes their turn  kind of is part of discard and do action

    # no card was chosen so choose a random card
    # else

    #   #     #take random card
    #   #array for displaying hand and array which has disabled
    #   @discard_pile.push(discard())

    #   puts "random discard is " + discard()
    #   # push to discard pile

    #   # remove from hand
    #   #make function for this
    #   #discard card, add to discard pile, call cpuaction
    #   pile_name = "hand"
    #   hand_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
    #   @hand = api_response(hand_list, "piles").fetch(pile_name).fetch("cards")

    #   discarded_arr = []

    #   @discarded_card = ""

    #   #check what card(s) were discarded from hand and change hand accordingly
    #   @hand.each do |h|
    #     if h == @discard
    #       discarded_arr.push(h)
    #     end
    #   end

    #   @curr_hand = []
    #   @hand.each do |h|
    #     @curr_hand.push(h.fetch("code"))
    #   end
    #   @discarded_card = discarded_arr.join(",")

    #   @text.push("You discarded the #{discarded_value} of #{discarded_suit}")
  end # end for random if

  cookies[:discard_pile] = @discard_pile.join(",")

  top_val = cookies[:disc_val]
  top_suit = cookies[:disc_suit]

  puts "hand_arr length is " + @hand_arr.length.to_s

  erb(:discard)
end

get("/draw") do

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
    pile_name = "deck"
    @draw = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"
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

  @hand_objs = []
  @image = []
  @code_arr = []
  @hand.each do |h|
    @image.push(h.fetch("image"))
    @code_arr.push(h.fetch("code"))
    @hand_objs.push(Hand.new(h.fetch("code"), h.fetch("image"), h.fetch("value"), h.fetch("suit")))
  end
  #in above hand each add everything necessary to array of objects

  ################################################### end of making draw work

  ################################################### start of disabled logic

  @discard_pile = cookies[:discard_pile].split(",")

  @discard_pile.each_with_index do |d, i|
    if i == @discard_pile.length - 1
      @top_discard = d #image need code,value,suit
    end
  end
  #get code from image string
  top_code = @top_discard.gsub(/[A-Z]/, "")

  cookies[:top_code] = top_code

  #this gives last one done by cpu i need the actual last discard
  # if cookies[:last_val] == nil
  #   top_val = cookies[:cpu_val]
  #   top_suit = cookies[:cpu_suit]
  # else
  #   top_val = cookies[:cpu_val]
  #   top_suit = cookies[:last_suit]
  # end

  #get last added card which would be on top of discard pile
  @discard_arr = []

  images = []

  @text = []

  @text.push("You drew a card") #discarded the #{discarded_value} of #{discarded_suit}")

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []

  top_val = cookies[:disc_val]
  top_suit = cookies[:disc_suit]

  #has code for cards in hand

  # must make a class which i can use to get the needed attributes
  @hand_objs.each_with_index do |c, i|

    #this code should still work with this project I think i just need to change the whole thing from checkboxes to radio buttons bc i only need to choose one
    if !(c.value == top_val || c.suit == top_suit || c.value == "KING" || c.value == "ACE")
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
  # puts @top_discard

  #this has to be here to get top discard
  # cpu_action(@top_discard.fetch("value"), @top_discard.fetch("suit"))
  cpu_action(top_val, top_suit)

  #try to update value and suit to make discarding in draw work
  cookies[:disc_val] = top_val
  cookies[:disc_suit] = top_suit

  erb(:draw)
end

get ("/result") do
  fetched = params.fetch(result)

  if fetched == win
    @result = win
  else
    @result = lose
  end
  erb(:result)
end
