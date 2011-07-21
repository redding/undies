module Undies; end
class Undies::Utils
  class << self

    def selector_opts(str='')
      # if str is a selector string
      if str =~ /^[#|\.]/
        # parse out id and class attrs using regex/handlers
        { :id => {
            :re => /#([\w|-]+)/,
            :proc => Proc.new {|captures| captures.last}
          },
          :class => {
            :re => /\.([\w|-]+)/,
            :proc => Proc.new {|captures| captures.join(' ')}
          }
        }.inject({}) do |opts, k_v|
          if (str =~ k_v.last[:re])
            opts[k_v.first] = k_v.last[:proc].call(parse(str, k_v.last[:re]))
          end
          opts
        end
      else
        # if str is not a selector, assume it's just an id attr
        {:id => str}
      end.reject do |k,v|
        # remove any blank stuff
        v.nil? || v.empty?
      end
    end

    private

    def parse(str, regex)
      captures = []
      while str =~ regex
        captures << $1
        str = $'
      end
      captures
    end


  end
end