# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for TODO/FIXME/etc comments.
      #
      # Avoid TODO comments, instead create tasks for them in your project
      # management software, and assign them to the right person. Half of the
      # TODOs usually never get done, and the code is then polluted with old
      # stale TODOs. Sometimes developers really mean to work on their TODOs
      # soon, but then Product re-prioritizes their work, or the developer
      # leaves the company, and never gets a chance to tackle them.
      class NoTodos < Base
        MSG = 'Avoid TODO comment, create a task in your project management tool instead.'
        KEYWORD_REGEX = /(^|[^\w])(TODO|FIXME|OPTIMIZE|HACK)($|[^\w])/i

        def on_new_investigation
          processed_source.comments.each do |comment|
            add_offense(comment) if comment.text.match?(KEYWORD_REGEX)
          end
        end
      end
    end
  end
end
