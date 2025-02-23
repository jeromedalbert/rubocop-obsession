# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for validation methods that do not start with `validate_`.
        #
        # @example
        #   # bad
        #   validate :at_least_one_admin
        #
        #   # good
        #   validate :validate_at_least_one_admin
        class ValidationMethodName < Base
          MSG = 'Prefix custom validation method with validate_'

          def_node_matcher :on_validate_callback, <<~PATTERN
            (send nil? :validate (sym $_) ...)
          PATTERN

          def on_send(node)
            on_validate_callback(node) do |method_name|
              add_offense(node) if !method_name.start_with?('validate_')
            end
          end
        end
      end
    end
  end
end
