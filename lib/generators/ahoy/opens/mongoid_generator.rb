require "rails/generators"

module Ahoy
  module Generators
    module Opens
      class MongoidGenerator < Rails::Generators::Base
        source_root File.join(__dir__, "templates")

        def copy_templates
          template "mongoid.rb", "app/models/ahoy/open.rb"
        end
      end
    end
  end
end
