# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for Rails callbacks with multiple fields.
        #
        # One method per callback definition makes the definition extra clear.
        #
        # @example
        #
        #   # bad
        #   after_create :notify_followers, :send_stats
        #
        #   # good
        #   after_create :notify_followers
        #   after_create :send_stats
        class CallbackOneMethod < Cop
          include Helpers

          MSG = 'Declare only one method per callback definition.'

          def_node_matcher :on_callback, <<~PATTERN
            (send nil? $_ (sym _) (sym _) ...)
          PATTERN

          def on_send(node)
            on_callback(node) { |callback| add_offense(node) if rails_callback?(callback.to_s) }
          end
        end
      end
    end
  end
end
