module Undies
  class Buffer < ::Array

    def to_s(pretty_print=false)
      # TODO: incorp pretty printing the HTML in the buffer
      self.join('')
    end

  end
end