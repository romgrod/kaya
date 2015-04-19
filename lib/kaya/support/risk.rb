module Kaya
  module Support
    class Risk
      def self.secure? value
        value.scan(/&&|kill.*|rm -rf|rm -r \.\[\^\.\]\*|mkfs.*|.*\> \/dev\/sda|\:\(\)\{\:\|\:\&\}\;\:|wget .*|sh \.\/.*|\||grep|python \-c \'import os.*|mv .+|\> .+|\^foo\^bar|dd if=\/dev\/random of=\/dev\/sda|mkdir .*/).empty?
      end
    end
  end
end
