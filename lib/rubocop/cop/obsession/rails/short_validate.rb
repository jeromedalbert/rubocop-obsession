# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for `validate` declarations that could be shorter.
        #
        # @example
        #
        #   # bad
        #   validate :validate_url, on: %i(create update)
        #
        #   # good
        #   validate :validate_url
        class ShortValidate < Cop
          MSG = 'The `on:` argument is not needed in this validate.'

          def_node_matcher :validate_with_unneeded_on?, <<~PATTERN
            (
              send nil? :validate
                (sym _)
                (hash
                  (pair (sym :on) (array <(sym :create) (sym :update)>))
                )
            )
          PATTERN

          def on_send(node)
            add_offense(node) if validate_with_unneeded_on?(node)
          end
        end
      end
    end
  end
end
