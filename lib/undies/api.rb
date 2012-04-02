require 'undies/raw'

module Undies
  module API

    def raw(string)
      Raw.new(string)
    end

  end
end
