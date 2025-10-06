require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "sinatra/contrib"
require_relative "hand"

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
  # puts "deck in cpu() is #{deck}"
  pile_name = "deck"
  cpu_url = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=7"
  # puts "cpu url is #{cpu_url}"
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

  cookies[:cpu_cards] = (@cpu_card_arr.join(","))

  cookies[:cpu_codes] = @cpu_code_arr.join(",")
  cookies[:cpu_values] = (values.join(","))
  cookies[:cpu_suits] = (suits.join(","))

  puts cookies[:cpu_cards].split(",")

  puts cookies[:cpu_codes].split(",")
  puts cookies[:cpu_values].split(",")
  puts cookies[:cpu_suits].split(",")

  cpu_hand = @cpu_code_arr.join(",")
  pile_name = "cpu_hand"

  #add hand before discarding from pile is this necessary? idk i could just add the cards to the pile but whatever or i could make the pile in the game action
  @c_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + cpu_hand

  resp = HTTP.get(@c_pile)

  pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  cards_res = api_response(pile, "piles").fetch(pile_name).fetch("cards")

  @c_image = []

  #scrapping this idea for now # add all values to array and iterate by 4s to get next one 0 is code 4 is next code
  # cpu_hand = []

  cards_res.each do |c|
    @c_image.push(c.fetch("image"))
    #card_code, card_img, value, suit

    #set
    # cpu_hand.push(c.fetch("code") + "," + c.fetch("image") + "," + c.fetch("value") + "," + c.fetch("suit"))
  end

  # puts cpu_hand
  #try to turn array into json to store in session

  ################################################### end of making cpu hand
  #  return cards_res
# try to make it so jack and queen only affects the cpu once; like i discard jack and my second action would be to draw cpu should then take its turn
  cookies[:jq_cnt] = 0

end

####################################################################################################################

def cpu_action(value, suit)
  #see if any errors pop up when i just put all the code for cpu discard here *************************************************************
  deck = cookies[:deck_id]

  # pile_name = "cpu_hand"
  # pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  # @cpu_h_cards = api_response(pile, "piles").fetch(pile_name).fetch("cards")
  # # cpu_cards = cookies[:cpu_cards].split(",")

  #check which cards match what i discarded
  #cpu_hand = cookies[:cpu_hand].split(",")
  # cpu_h_codes = []
  cpu_h_vals = []
  cpu_h_suits = []
  # do i need these if i already have session values to use?
  # @cpu_h_cards.each do |c|
  #   cpu_h_codes.push(c.fetch("code"))
  #   cpu_h_vals.push(c.fetch("value"))
  #   cpu_h_suits.push(c.fetch("suit"))
  # end
  deck = cookies[:deck_id]

  @cpu_h_cards = cookies[:cpu_cards].split(",")

  cpu_h_codes = cookies[:cpu_codes].split(",")

  values = cookies[:cpu_values].split(",")

  cpu_h_suits = cookies[:cpu_suits].split(",")

  #variable true if cpu has discarded all necessary cards
  has_discarded = false

  

  # session[:jack_used] = false
  # session[:queen_used] = false

  #bool to make it so cpu gets to go again when it discards j or q
  cookies[:cpu_jq] = "false"
  # puts "Jack used before if val == jack is #{session[:jack_used]}"
  # puts "Queen used before if val == jack is #{session[:queen_used]}"
  # if last discarded card was a jack or queen the cpu skips its turn
  if ((value == "JACK" || value == "QUEEN") && cookies[:jq_cnt] != "1")#&& cookies[:cpu_jq] != true
    # if session[:jack_used] != true || session[:queen_used] != true
      # puts session[:jack_used].to_b == false
    puts "this should be the only thing that happens and new cards are still available for cpu_action"
    # @text.push("Player discarded a #{value}, skipping the CPU's turn.")
    # session[:text] =   @text.join(",")
# puts cookies[:jq_cnt] + " is jq cnt"
    # if value == "JACK"
    #   session[:jack_used] = true
    # elsif value == "QUEEN"
    #   session[:queen_used] = true
    # end
puts value == ("JACK" || value == "QUEEN") && cookies[:jq_cnt] != "1"
# puts cookies[:jq_cnt] != "1"
# puts cookies[:jq_cnt] == "1"
    cookies[:jq_cnt] = "1"
    puts cookies[:jq_cnt] == "1"
    # puts "Jack used in if val == jack is #{session[:jack_used]}"
    #   puts "Queen used in if val == jack is #{session[:queen_used]}"
  # end
  else
    heart_cnt = 0
    dmnd_cnt = 0
    spade_cnt = 0
    club_cnt = 0

    # session[:jack_used] = false
    # session[:queen_used] = false

    #   puts "Jack used in else is #{session[:jack_used]}"
    # puts "Queen used in else is #{session[:queen_used]}"

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

    # @cpu_h_cards.each_with_index do |h, i|
    #   if value == h.fetch("value") || suit == h.fetch("suit") || h.fetch("value") == "KING" || h.fetch("value") == "ACE"
    #     discarded = h.fetch("code")
    #     cpu_can_discard.push(h)
    #     cpu_d_val = h.fetch("value")
    #     cpu_d_suit = h.fetch("suit")
    #   end
    # end

    # changed to have session values
    cpu_h_codes.each_with_index do |c, i|
      if value == values[i] || suit == cpu_h_suits[i] || values[i] == "KING" || values[i] == "ACE"
        discarded = c
        # puts "discarded is " + discarded
        cpu_can_discard.push(c)
        cpu_d_val = values[i]
        cpu_d_suit = cpu_h_suits[i]
        puts "values at i is " + values[i]
        puts "cpu_h_suits at i is " + cpu_h_suits[i]
        
      end
    end

    #discarded value and discarded suit to be used for player hand to skip
    cookies[:cpu_val] = cpu_d_val
    cookies[:cpu_suit] = cpu_d_suit

    if cpu_can_discard.length == 0
      cant_discard = true
    end

    #if not able to discard
    if cant_discard
      pile_name = "deck"
      #draw from deck
      draw_cpu = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=1"

      cpu_draw = api_response(draw_cpu, "cards")

      drawn_cpu_card = ""
      drawn_cpu_value = ""
      drawn_cpu_suit = ""
      drawn_cpu_img = ""
      cpu_draw.each do |c|
        drawn_cpu_card = c.fetch("code")
        drawn_cpu_value = c.fetch("value")
        drawn_cpu_suit = c.fetch("suit")
        drawn_cpu_img = c.fetch("image")
      end
      #puts "drawn cpu card is: #{drawn_cpu_card}"

      #update cpu hand
      cpu_h_codes.push(drawn_cpu_card)
      values.push(drawn_cpu_value)
      cpu_h_suits.push(drawn_cpu_suit)
      @cpu_h_cards.push(drawn_cpu_img)

      pile_name = "cpu_hand"
      #add to cpu_hand
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + drawn_cpu_card
      s = api_response(pile, "piles").fetch(pile_name)

      if session[:text] != nil
        @text.push("\n\nCPU draws #{drawn_cpu_value} of #{drawn_cpu_suit}")
        session[:text] = session[:text] + "," + @text.join(",")
      else
        session[:text] = @text.join(",")
      end
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
        # puts "max suit in king if is #{max_suit}"

        king_cnt += 1
        cookies[:king_cnt] = king_cnt
        #discard discarded from cpu hand in order to return from deck
        pile_name = "cpu_hand"
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
        res = HTTP.get(pile)

        #update cpu_hand
        #find index of code discarded
        #set that index to next card until every card is updated to new index basically every card moves up one index
        # that should be end of updating after updating every array -> now i remember why i thought this wouldnt work, so many arrays here would changing to hash somehow work?
        #try .select! to change array like that

        #got index of discarded
        disc_index = cpu_h_codes.index(discarded)
        # puts "cpu hand code at discarded is " + cpu_h_codes[disc_index]
        #.select! to remove discarded from codes
        cpu_h_codes.select! { |code| code != discarded }

        #.select! to remove discarded from cards
        @cpu_h_cards.select! { |card| @cpu_h_cards.index(card) != disc_index }

        #.select! to remove discarded from cpu_h_suits
        cpu_h_suits.select! { |suit| cpu_h_suits.index(suit) != disc_index }

        #.select! to remove discarded from values
        values.select! { |val| values.index(val) != disc_index }

        #set to true because now discarded cant be drawn again
        # has_discarded = true

        # return king from cpu hand to deck that way won't be drawing infinite kings and aces nah i need a counter for kings and aces that way ill only return those cards to the deck once enough have been used
        #return king to deck only if no more using them
        if king_cnt == 4
          return_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/return/?cards=" + discarded

          kdc = api_response(return_dc, "cards")[0]
          has_discarded = true
        else
          # add discarded back to deck pile to use again
          pile_name = "deck"
          deck_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded

          kdc = api_response(deck_dc, "success")
          has_discarded = true

          # make sure not trying to draw and discard same card again
          if (discarded != dis_c_king)
            n_king_in_hand_arr = []
            if @hand_arr != nil
              if @hand_arr.include?(dis_c_king)
                puts "@hand_arr has dis_c_king"
                #draw from hand pile
                #see if player hand does not have king that cpu needs to discard
              end
            
            elsif @hand != nil #should be when @hand is not nil
              # n_king_in_hand_arr.push(@hand[@hand.index(dis_c_king)])
              if @hand.include?(dis_c_king)
                puts "@hand has dis_c_king"
              #draw from hand pile
              end
              if n_king_in_hand_arr != nil #if player does have card
                #draw card from hand
                pile_name = "hand"
                p_h = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + dis_c_king

                pile_name = "discard"
                pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + dis_c_king
                res = HTTP.get(pile)

                @text.push("\n\nCPU discards KING of #{max_suit}")
                if session[:text] != nil
                  session[:text] = session[:text] + "," + @text.join(",")
                else
                  session[:text] = @text.join(",")
                end
              else # i think i need to change this else to be drawing card from player hand
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

                if session[:text] != nil
                  @text.push("\n\nCPU discards #{kdc_val} of #{kdc_suit}")
                  #only add session:text to text if action is not draw for player
                  if @did_draw != nil && @did_draw == "next_draw"
                    session[:text] = @text.join(",")
                  else
                    session[:text] = session[:text].join(",") + "," + @text.join(",")
                  end
                else
                  @text.push("\n\nCPU discards #{kdc_val} of #{kdc_suit}")
                end # session text
              end # check for changed card being held in hand ; might need to do the same for discard pile unless im doing it elsewhere
            end # if n_king_in_hand
          end # if discarded ! = dis_c_king
        end # king cnt maybe its switched around
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

        #got index of discarded
        disc_index = cpu_h_codes.index(discarded)

        #.select! to remove discarded from codes
        cpu_h_codes.select! { |code| code != discarded }

        #.select! to remove discarded from cards
        @cpu_h_cards.select! { |card| @cpu_h_cards.index(card) != disc_index }

        #.select! to remove discarded from cpu_h_suits
        cpu_h_suits.select! { |suit| cpu_h_suits.index(suit) != disc_index }

        #.select! to remove discarded from values
        values.select! { |val| values.index(val) != disc_index }

        if ace_cnt == 4
          return_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/return/?cards=" + discarded

          adc = api_response(return_dc, "cards")[0]
          adc_val = adc.fetch("value")
          adc_suit = adc.fetch("suit")
        else
          # puts "max suit in ace if is #{max_suit}"
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

          if (discarded != dis_c_ace)
            pile_name = "deck"
            #draw new ace in order to change king suit to max_suit
            ace_dc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + dis_c_ace

            adc = api_response(ace_dc, "cards")[0]
            adc_val = adc.fetch("value")
            adc_suit = adc.fetch("suit")

            pile_name = "discard"
            pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + dis_c_ace
            res = HTTP.get(pile)
            #makes it so that CPU can discard an ace and change it to the suit it has the most cards for

            # else # discarded card was not a king or ace and that means dont have to do anything special so only have to add discarded

            #   # add the discarded card to discard pile
            #   pile_name = "discard"
            #   @cd_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
            #   #res = HTTP.get(pile)
            #   d_cpu_res = api_response(@cd_pile, "piles") #.fetch(pile_name).fetch("cards")
            if session[:text] != nil
              @text.push("\n\nCPU discards #{adc_val} of #{adc_suit}")
              session[:text] = session[:text].join(",") + "," + @text
            else
              @text.push("\n\nCPU discards #{adc_val} of #{adc_suit}")
            end
          end
        end

        #elsif jack or queen then cpu_action

      end #if statement for aces and kings

      #in else for cant discard so that means able to discard here
      #so whats happening is that i think bc i discarded the card already earlier its trying to discard here
      # draw the card from the cpu hand i guess check why it doesnt work like this i thought it was in else and wouldnt be affected the king or ace discard

      #THIS CODE IS ABSOLUTELY NECESSARY I JUST REALLY NEED TO FIND OUT HOW TO GET IT TO WORK I NEED TO DISCARD THE CARD IF ITS NOT AN ACE AND NOT A KING
      if !has_discarded
        pile_name = "cpu_hand"
        @ch_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + discarded
        #res = HTTP.get(pile)

        #got index of discarded
        disc_index = cpu_h_codes.index(discarded)

        #.select! to remove discarded from codes
        cpu_h_codes.select! { |code| code != discarded }
        # puts "codes after select are #{cpu_h_codes}"
        #.select! to remove discarded from cards
        @cpu_h_cards.select! { |card| @cpu_h_cards.index(card) != disc_index }

        #.select! to remove discarded from cpu_h_suits
        cpu_h_suits.select! { |suit| cpu_h_suits.index(suit) != disc_index }

        #.select! to remove discarded from values
        values.select! { |val| values.index(val) != disc_index }

        pile_name = "discard"
        pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + discarded
        res = HTTP.get(pile)

        if session[:text] != nil
          if session[:text].is_a?(String)
            @text.push("\n\nCPU discards #{cpu_d_val} of #{cpu_d_suit}")
            session[:text] = session[:text] + "," + @text.join(",")
            puts cpu_d_val + " in text push for regular card session is string"
          puts cpu_d_suit + " in text push for regular card session is string"
          elsif session[:text].is_a?(Array)
            @text.push("\n\nCPU discards #{cpu_d_val} of #{cpu_d_suit}")
            session[:text] = session[:text].join(",") + "," + @text.join(",")
            puts cpu_d_val + "in text push for regular card session is array"
          end
        else
          @text.push("\n\nCPU discards #{cpu_d_val} of #{cpu_d_suit}")
          puts cpu_d_val + " in text push for regular card no session"

        end
        #if cpu discards jack or queen they get to go again
        if cpu_d_val == "JACK" || cpu_d_val == "QUEEN"
          #cpu discards jack or queen in order to go again i include bool in order differentiate from player discarded and cpu discarded j or q
          cookies[:cpu_jq] = true
          cpu_action(cpu_d_val, cpu_d_suit)
        end
      end # end if to check if card was already discarded from cpu_hand
    end #if for can't discard

    #return new_cards

    #for some reason having just the methods here messes up later code for getting the hand pile discard_res

  end # if with jack/queen

  # end # if for jac/queen
  session[:jack_used] = false
  session[:queen_used] = false
  # puts "Jack used outside of ifs is #{session[:jack_used]}"
  #   puts "Queen used outside of ifs is #{session[:queen_used]}"

  pile_name = "cpu_hand"
  @chl_pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"
  @new_cards = api_response(@chl_pile, "piles").fetch(pile_name).fetch("cards")

  cookies[:cpu_cards] = @cpu_h_cards.join(",")
  cookies[:cpu_codes] = cpu_h_codes.join(",")
  cookies[:cpu_suits] = cpu_h_suits.join(",")
  cookies[:cpu_values] = values.join(",")

  # @new_images = []
  # @new_cards.each do |n|
  #   @new_images.push(n.fetch("image"))
  # end #end loop

end #end function

# helpers do
#   def text
#     @text = session[:text] || = ""
#   end
# end

get("/") do
  # session.clear
  erb(:home)
end

get("/game") do

  #clear session if it hasnt already been cleared
  #   if session != {}
  #   session.clear
  # end
  #make sure to reset king counter everytime new game starts
  cookies[:king_cnt] = 0

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

  #see if drawing extra aces and kings fixes issues of CPU hand not having kings and aces
  # pile_name = "extras"
  # extra_cards = "AS,AC,AH,AD,KS,KC,KH,KD"
  # pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + extra_cards

  #***********************************************************end of extra kings aces logic
  #start game by drawing 7 cards
  pile_name = "deck"
  start_game = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?count=7"
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

  ################################################### start of adding player 2 to game in other words the CPU - goes in game
  ################################################### end of adding player 2 to game in other words the CPU - goes in game

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
  # puts "@first card: #{@first_card}"
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

  @is_king = false

  @text = []

  d_res = []

  #these arrs holds all kings and aces used to check if king or ace cpu is looking for is in player's hand
  k_arr = []
  a_arr = []
  #if to check which king card is being discarded; it would be chosen from button so fetch king
  if params.key?("king")
    # i will most likely have to disable discard when king is selected in hand
    king_p = params.fetch("king")

    discarded_value = ""
    discarded_suit = ""
    case king_p
    when "KS"
      discarded_value = "KING"
      discarded_suit = "SPADES"
    when "KC"
      discarded_value = "KING"
      discarded_suit = "CLUBS"
    when "KH"
      discarded_value = "KING"
      discarded_suit = "HEARTS"
    when "KD"
      discarded_value = "KING"
      discarded_suit = "DIAMONDS"
    end

    pile_name = "hand"
    #need to draw king from hand and do not add to discard just add back to deck pile unless kingcnt = 4 then return to deck then draw new king from deck and that to discard
    king_hd = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard
    api_response(king_hd, "success")

    king_cnt = cookies[:king_cnt].to_i

    king_cnt += 1

    if king_cnt == 4
      #return king from hand to deck and no longer draw any kings
      pile_name = "deck"
      return_kdc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/return/?cards=" + @discard
      api_response(return_dc, "success")

      # still need to add new king to discard pile
      pile_name = "discard"
      dis_kdc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + king_p
      api_response(dis_kdc, "success")

      #  discarded_value = res_k.fetch("value")
      #  discarded_suit = res_k.fetch("suit")

    else

      #otherwise return to deck pile
      pile_name = "deck"
      deck_king = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @discard
      api_response(deck_king, "success")

      # and add new king to discard pile
      pile_name = "discard"
      dis_kdc = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + king_p
      api_response(dis_kdc, "success")

      # discarded_value = res_k.fetch("value")
      # discarded_suit = res_k.fetch("suit")
    end
  else # no king value to be discarded so discard normally
    
      # drwing from hand here
      pile_name = "hand"

      #draw from the pile which would be discarding in this case; this discards chosen card from hand
      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/draw/?cards=" + @discard

      d_res = api_response(pile, "cards")

      discarded_value = ""
      discarded_suit = ""
      d_res.each do |d|
        discarded_value = d.fetch("value")
        discarded_suit = d.fetch("suit")
      end
      #/pile/discard is name of pile - its discard
      pile_name = "discard"

      pile = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/add/?cards=" + @discard

      resp = HTTP.get(pile)

      raw_response = resp.to_s

      parsed_response = JSON.parse(raw_response)

      #end of if for king/ace

      # will need to do discarded value and suit for king/ace
    
  end
  # end
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

  #last place @text was in
  #join text add to cookies and split and assign in draw
  # try making @text "global"
  if session[:text] != nil
    @text.push(session[:text])
    @text.push("You discarded the #{discarded_value} of #{discarded_suit}")
    session[:text] = @text.join(",")
    puts session[:text]
  else
    @text.push("You discarded the #{discarded_value} of #{discarded_suit}")
    session[:text] = @text.to_s
    puts session[:text]
  end
  #end of if for checking king was selected already discarding that card so else is when discarding other cards

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

  #original spot for cpu_action before moving it right before getting hand list

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

  #might not need anymore but ill still use is king
  # @is_king = false
  # if @top_discard.fetch("value") == "KING"
  #   @is_king = true
  # end

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
  # session[:hand] = @hand.join("!")

  ################################################### end of making draw work

  ################################################### start of disabled logic

  pile_name = "discard"

  discard_list = "https://deckofcardsapi.com/api/deck/" + deck + "/pile/" + pile_name + "/list/"

  @discard_res = api_response(discard_list, "piles").fetch(pile_name).fetch("cards")

  #get last added card which would be on top of discard pile
  @discard_arr = []

  images = []

  @discard_res.each_with_index do |d, i|
    @in = i
    @dlen = @discard_res.length
    if i == @discard_res.length - 1
      @top_discard = d
    end

    images.push(d.fetch("image"))
  end

  # needs to be here so @text works in cpu_action
  if session[:text] != nil
    @text = session[:text].split(",")
  else
    @text = []
  end

  @text.push("You drew a card") #discarded the #{discarded_value} of #{discarded_suit}")

  if session[:text] != nil
    session[:text] = session[:text].join(",") + "," + @text.join(",")
  else
    session[:text] = @text
  end

  # @hand = session[:hand].split("!")

  # this has to be done here so discard pile is properly updated
  images.each do |i|
    @discard_arr.push(i)
  end

  #@top_discard.class
  #make it so the cards that do not match the most recent card are disabled

  #make array that's filled with cards that do not match the suit or value of card in discard pile or are not king or ace cards
  @disabled_arr = []
  @disable = []
  #has code for cards in hand

  # must make a class which i can use to get the needed attributes
  @hand_objs.each_with_index do |c, i|

    #this code should still work with this project I think i just need to change the whole thing from checkboxes to radio buttons bc i only need to choose one
    if !(c.value == @top_discard["value"] || c.suit == @top_discard["suit"] || c.value == "KING" || c.value == "ACE")
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
  cpu_action(@top_discard.fetch("value"), @top_discard.fetch("suit"))

  erb(:draw)
end
