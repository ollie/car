module Sinatra
  module AppHelpers
    def format_number(number, format: '%.02f')
      format(format, number).tap do |s|
        s.reverse!
        s.gsub!(/(\d{3})(\d)/, '\1 \2')
        s.tr!('.', ',')
        s.reverse!
      end
    end
  end
end
