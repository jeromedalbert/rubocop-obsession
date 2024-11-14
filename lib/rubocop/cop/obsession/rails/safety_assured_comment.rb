# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks uses of strong_migrations' `safety_assured { ... }`
        # without a valid reason.
        #
        # `safety_assured { ... }` should only be used after *carefully*
        # following the instructions from the strong_migrations gem. Always add a
        # `# Safe because <reason>` comment explaining how you assured the safety
        # of the DB migration. The reason should be detailed and reviewed by a
        # knowledgeable PR reviewer. Failure to follow instructions may bring your
        # app down.
        #
        # @example
        #
        #   # bad
        #   class RemoveSourceUrlFromBlogPosts < ActiveRecord::Migration[8.0]
        #     def change
        #       safety_assured { remove_column :blog_posts, :source_url }
        #     end
        #   end
        #
        #   # good
        #   class RemoveSourceUrlFromBlogPosts < ActiveRecord::Migration[8.0]
        #     # Safe because this column was ignored with self.ignored_columns in PR #1234
        #     def change
        #       safety_assured { remove_column :blog_posts, :source_url }
        #     end
        #   end
        class SafetyAssuredComment < Base
          MSG =
            'Add `# Safe because <reason>` comment above safety_assured. ' \
              'An invalid reason may bring the site down.'

          def_node_matcher :safety_assured_block?, <<~PATTERN
            (block (send nil? :safety_assured) ...)
          PATTERN

          def on_block(node)
            return if !safety_assured_block?(node)
            previous_comment = processed_source.comments_before_line(node.first_line)&.last

            if previous_comment.nil? || !previous_comment.text.match?(/^# Safe because( [^ ]+){4}/)
              add_offense(node)
            end
          end
        end
      end
    end
  end
end
