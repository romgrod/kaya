# encoding: utf-8

module Kaya
  module Support
    module Logo
      def self.show
        puts self.logo
      end

      def self.logo
        "
    ██╗  ██╗ █████╗ ██╗   ██╗ █████╗
    ██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔══██╗
    █████╔╝ ███████║ ╚████╔╝ ███████║
    ██╔═██╗ ██╔══██║  ╚██╔╝  ██╔══██║
    ██║  ██╗██║  ██║   ██║   ██║  ██║
    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
             Version #{Kaya::VERSION}
  "
      end
    end
  end
end