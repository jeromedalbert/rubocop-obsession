# frozen_string_literal: true

module RuboCop
  module Cop
    module Helpers
      VERBS = File.read("#{__dir__}/files/verbs.txt").split

      def rails_callback?(callback)
        return true if callback == 'validate'

        callback.match?(
          /
        ^(before|after|around)
        _.*
        (action|validation|create|update|save|destroy|commit|rollback)$
        /x
        )
      end

      def verb?(string)
        short_string = string[2..] if string.start_with?('re')

        VERBS.include?(string) || VERBS.include?(short_string)
      end
    end
  end
end
