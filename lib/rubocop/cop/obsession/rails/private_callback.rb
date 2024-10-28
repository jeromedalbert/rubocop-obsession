# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for callbacks methods that are not private.
        #
        # Callback methods are usually never called outside of the class, so
        # there is no reason to declare them in the public section. They should
        # be private.
        #
        # @example
        #
        #   # bad
        #   before_action :load_blog_post
        #
        #   def load_blog_post
        #     ...
        #   end
        #
        #   # good
        #   before_action :load_blog_post
        #
        #   private
        #
        #   def load_blog_post
        #     ...
        #   end
        class PrivateCallback < Base
          include VisibilityHelp
          include Helpers

          MSG = 'Make callback method private'

          def_node_matcher :on_callback, <<~PATTERN
            (send nil? $_ (sym $_) ...)
          PATTERN

          def on_new_investigation
            @callbacks = Set.new
          end

          def on_send(node)
            on_callback(node) do |callback, method_name|
              @callbacks << method_name if rails_callback?(callback.to_s)
            end
          end

          def on_def(node)
            if @callbacks.include?(node.method_name) && node_visibility(node) == :public
              add_offense(node, message: MSG)
            end
          end
        end
      end
    end
  end
end
