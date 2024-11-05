# frozen_string_literal: true

module RuboCop
  module Cop
    module Helpers
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

        verbs.include?(string) || verbs.include?(short_string)
      end

      private

      def verbs
        @@verbs ||= File.read("#{__dir__}/files/verbs.txt").split
      end
    end
  end
end
