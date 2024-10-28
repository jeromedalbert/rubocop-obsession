# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for `validates` callbacks with multiple fields.
        #
        # One field per `validates` makes the validation extra clear.
        #
        # @example
        #
        #   # bad
        #   validates :name, :status, presence: true
        #
        #   # good
        #   validates :name, presence: true
        #   validates :status, presence: true
        class ValidateOneField < Base
          MSG = 'Validate only one field per line.'

          def_node_matcher :validates_with_more_than_one_field?, <<~PATTERN
            (send nil? :validates (sym _) (sym _) ...)
          PATTERN

          def on_send(node)
            add_offense(node) if validates_with_more_than_one_field?(node)
          end
        end
      end
    end
  end
end
