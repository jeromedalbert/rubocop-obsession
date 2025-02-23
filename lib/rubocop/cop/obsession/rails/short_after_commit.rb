# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for `after_commit` declarations that could be shorter.
        #
        # @example
        #   # bad
        #   after_commit :send_email, on: :create
        #
        #   # good
        #   after_create_commit :send_email
        class ShortAfterCommit < Base
          MSG = 'Use shorter %<prefer>s'

          def_node_matcher :after_commit?, '(send nil? :after_commit ...)'

          def_node_matcher :after_commit_create?, <<~PATTERN
            (
              send nil? :after_commit
                (sym _)
                (hash
                  (pair (sym :on) {(sym :create)|(array (sym :create))})
                )
            )
          PATTERN

          def_node_matcher :after_commit_update?, <<~PATTERN
            (
              send nil? :after_commit
                (sym _)
                (hash
                  (pair (sym :on) {(sym :update)|(array (sym :update))})
                )
            )
          PATTERN

          def_node_matcher :after_commit_destroy?, <<~PATTERN
            (
              send nil? :after_commit
                (sym _)
                (hash
                  (pair (sym :on) {(sym :destroy)|(array (sym :destroy))})
                )
            )
          PATTERN

          def_node_matcher :after_commit_create_update?, <<~PATTERN
            (
              send nil? :after_commit
                (sym _)
                (hash
                  (pair (sym :on) (array <(sym :create) (sym :update)>))
                )
            )
          PATTERN

          def_node_matcher :after_commit_all_events?, <<~PATTERN
            (
              send nil? :after_commit
                (sym _)
                (hash
                  (pair (sym :on) (array <(sym :create) (sym :update) (sym :destroy)>))
                )
            )
          PATTERN

          def on_send(node)
            return if !after_commit?(node)

            if after_commit_create?(node)
              add_offense(node, message: format(MSG, prefer: 'after_create_commit'))
            elsif after_commit_update?(node)
              add_offense(node, message: format(MSG, prefer: 'after_update_commit'))
            elsif after_commit_destroy?(node)
              add_offense(node, message: format(MSG, prefer: 'after_destroy_commit'))
            elsif after_commit_create_update?(node)
              add_offense(node, message: format(MSG, prefer: 'after_save_commit'))
            elsif after_commit_all_events?(node)
              add_offense(node, message: format(MSG, prefer: 'after_commit with no `on:` argument'))
            end
          end
        end
      end
    end
  end
end
