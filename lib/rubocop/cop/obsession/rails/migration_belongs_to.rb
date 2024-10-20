# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for migrations that use `references` instead of `belongs_to`.
        #
        # Instead of adding `references` in migrations, use the `belongs_to`
        # alias. It reads nicer and is more similar to the `belongs_to`
        # declarations that you find in model code.
        #
        # @example
        #
        #   # bad
        #   def change
        #     add_reference :blog_posts, :user
        #   end
        #
        #   # good
        #   def change
        #     add_belongs_to :blog_posts, :user
        #   end
        class MigrationBelongsTo < Cop
          def_node_matcher :add_reference?, <<~PATTERN
            (send nil? :add_reference ...)
          PATTERN

          def_node_matcher :table_reference?, <<~PATTERN
            (send (lvar :t) :references ...)
          PATTERN

          def on_send(node)
            if add_reference?(node)
              add_offense(node, message: 'Use add_belongs_to instead of add_reference')
            elsif table_reference?(node)
              add_offense(node, message: 'Use t.belongs_to instead of t.references')
            end
          end
        end
      end
    end
  end
end
