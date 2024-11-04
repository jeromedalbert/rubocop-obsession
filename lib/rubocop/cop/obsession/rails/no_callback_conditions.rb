# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for model callbacks with conditions.
        #
        # Model callback with conditions should be avoided because they can
        # quickly degenerate into multiple conditions that pollute the macro
        # definition section, even more so if lambdas are involved. Instead, move
        # the condition inside the callback method.
        #
        # Note: conditions are allowed for `validates :field` callbacks, as it is
        # sometimes not easy to translate them into `validate :validate_field`
        # custom validation callbacks.
        #
        # @example
        #
        #   # bad
        #   after_update_commit :crawl_rss, if: :rss_changed?
        #
        #   def crawl_rss
        #     ...
        #   end
        #
        #   # good
        #   after_update_commit :crawl_rss
        #
        #   def crawl_rss
        #     return if !rss_changed?
        #     ...
        #   end
        class NoCallbackConditions < Base
          MSG =
            'Avoid condition in callback declaration, move it inside the callback method instead.'

          def_node_matcher :callback_with_condition?, <<~PATTERN
            (
              send nil? _
                (sym _)
                (hash
                  ...
                  (pair (sym {:if :unless}) ...)
                  ...
                )
            )
          PATTERN

          def on_send(node)
            return if !callback_with_condition?(node)
            callback = node.children[1]
            return if callback == :validates
            return if callback.to_s.include?('around')

            add_offense(node)
          end
        end
      end
    end
  end
end
