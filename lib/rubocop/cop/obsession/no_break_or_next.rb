# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for `next` (and sometimes `break`) in loops.
      #
      # - For big loops, `next` or `break` indicates that the loop body has
      # significant logic, which means it should be moved into its own method,
      # and you can convert the `next` or `break` into `return` and the like.
      # - For small loops, you can just use normal conditions instead of `next`.
      # `break` is allowed.
      #
      # Note: Sometimes loops can also be rethought, like transforming a
      # `loop` + `break` into a `while`.
      #
      # @example
      #
      #   # bad
      #   github_teams.each do |github_team|
      #     next if github_team['size'] == 0
      #     team = @company.teams.find_or_initialize_by(github_team['id'])
      #
      #     team.update!(
      #       name: github_team['name'],
      #       description: github_team['description'],
      #       owner: @company,
      #     )
      #   end
      #
      #   # good
      #   github_teams.each do |github_team| { |github_team| upsert_team(github_team) }
      #
      #   def upsert_team(github_team)
      #     return if github_team['size'] == 0
      #     team = @company.teams.find_or_initialize_by(github_team['id'])
      #
      #     team.update!(
      #       name: github_team['name'],
      #       description: github_team['description'],
      #       owner: @company,
      #     )
      #   end
      #
      #   # bad
      #   def highlight
      #     blog_posts.each do |blog_post|
      #       next if !blog_post.published?
      #
      #       self.highlighted = true
      #     end
      #   end
      #
      #   # good
      #   def highlight
      #     blog_posts.each do |blog_post|
      #       if blog_post.published?
      #         self.highlighted = true
      #       end
      #     end
      #   end
      class NoBreakOrNext < Base
        BIG_LOOP_MSG =
          'Avoid `break`/`next` in big loop, decompose into private method or rethink loop.'
        NO_NEXT_MSG = 'Avoid `next` in loop, use conditions or rethink loop.'
        BIG_LOOP_MIN_LINES = 7

        def_node_matcher :contains_break_or_next?, <<~PATTERN
          `(if <({next break}) ...>)
        PATTERN

        def_node_matcher :contains_next?, <<~PATTERN
          `(if <(next) ...>)
        PATTERN

        def on_block(node)
          return if !contains_break_or_next?(node)

          if big_loop?(node)
            add_offense(node, message: BIG_LOOP_MSG)
          elsif contains_next?(node)
            add_offense(node, message: NO_NEXT_MSG)
          end
        end

        private

        def big_loop?(node)
          node.line_count >= BIG_LOOP_MIN_LINES + 2
        end
      end
    end
  end
end
