class Hand
  attr_accessor :card_code
  attr_accessor :card_img
  attr_accessor :value
  attr_accessor :suit
  
  def initialize(card_code, card_img, value, suit)
    @card_code = card_code
    @card_img = card_img
    @value = value
    @suit = suit
  end
end

    # self.card_code = card_code
    # self.card_img = card_img
    # self.value = value
    # self.suit = suit
