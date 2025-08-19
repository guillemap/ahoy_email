require "rails/generators"

module Ahoy
  module Generators
    class OpensGenerator < Rails::Generators::Base
      def copy_templates
        activerecord = defined?(ActiveRecord)
        mongoid = defined?(Mongoid)

        selection =
          if activerecord && mongoid
            puts <<~MSG

              Which data store would you like to use?
               1. Active Record (default)
               2. Mongoid
            MSG

            ask(">")
          elsif activerecord
            "1"
          else
            "2"
          end

        case selection
        when "", "1"
          invoke "ahoy:opens:activerecord"
        when "2"
          invoke "ahoy:opens:mongoid"
        else
          abort "Error: must enter a number [1-2]"
        end
      end
    end
  end
end
