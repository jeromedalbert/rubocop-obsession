# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for private/protected methods that are not ordered
      # correctly. It supports autocorrect.
      #
      # Code should read from top to bottom: methods should be defined in the
      # same order as the order when they are first mentioned.
      # Private/protected methods should follow that rule.
      #
      # Note 1: public methods do not have to follow that rule, and can be
      # defined in any order the developer wants, like by order of importance.
      # This is because they are usually called outside of the class and often
      # not called within the class at all. If possible though, developers
      # should still try to order their public methods from top to bottom when
      # it makes sense.
      #
      # Note 2: method order cannot be computed for methods called by `send`,
      # metaprogramming, private methods called by superclasses or modules,
      # etc. This cop's suggestions and autocorrections may be slightly off for
      # these kinds of edge cases.
      #
      # Note 3: for simplicity, protected methods do not have to follow that
      # rule if there are both a protected section and a private section.
      #
      # Note 4: for more information on this style of method ordering, see
      # Robert C. Martin's "Clean Code" book > "Chapter 3: Functions" > "One
      # level of abstraction per function" > "Reading Code from Top to Bottom:
      # The Stepdown Rule" chapter.
      #
      # @example
      #
      #   # bad
      #   def perform
      #     return if method_a?
      #     method_b
      #     method_c
      #   end
      #
      #   private
      #
      #   def method_c; ...; end
      #   def method_b; ...; end
      #   def method_a?; ...; end
      #
      #   # good
      #   def perform
      #     return if method_a?
      #     method_b
      #     method_c
      #   end
      #
      #   private
      #
      #   def method_a?; ...; end
      #   def method_b; ...; end
      #   def method_c; ...; end
      class MethodOrder < Base
        include Helpers
        include CommentsHelp
        include VisibilityHelp
        extend AutoCorrector

        MSG = 'Method `%<after>s` should appear below `%<previous>s`.'

        def_node_search :private_nodes, <<~PATTERN
          (send nil? {:private :protected})
        PATTERN

        def_node_matcher :on_callback, <<~PATTERN
          (send nil? $_ (sym $_) ...)
        PATTERN

        def_node_search :method_calls, <<~PATTERN
          (send nil? $_ ...)
        PATTERN

        class Node
          attr_accessor :value, :children

          def initialize(value:, children: [])
            @value = value
            @children = children
          end
        end

        def on_class(class_node)
          @class_node = class_node
          find_private_node || return
          build_methods || return
          build_callback_methods

          build_method_call_tree
          build_ordered_private_methods
          build_private_methods

          verify_private_methods_order
        end

        private

        def find_private_node
          private_nodes = private_nodes(@class_node).to_a
          return nil if private_nodes.empty?

          visibilities = private_nodes.map(&:method_name)
          @ignore_protected = visibilities.include?(:protected) && visibilities.include?(:private)

          @private_node = private_nodes.find { |node| !ignore_visibility?(node.method_name) }
        end

        def ignore_visibility?(visibility)
          case visibility
          when :public
            true
          when :protected
            @ignore_protected
          when :private
            false
          end
        end

        def build_methods
          @methods = {}
          return false if @class_node&.body&.type != :begin

          @class_node.body.children.each do |child|
            @methods[child.method_name] = child if child.type == :def
          end

          @methods.any?
        end

        def build_callback_methods
          @callback_methods = []

          @class_node.body.children.each do |node|
            on_callback(node) do |callback, method_name|
              if rails_callback?(callback.to_s) && @methods[method_name]
                @callback_methods << @methods[method_name]
              end
            end
          end
        end

        def build_method_call_tree
          methods = (@callback_methods + @methods.values).uniq

          @method_call_tree =
            Node.new(value: nil, children: methods.map { |method| method_call_tree(method) })
        end

        def method_call_tree(method_node, seen_method_calls = Set.new)
          method_name = method_node.method_name
          return nil if seen_method_calls.include?(method_name)
          called_methods = find_called_methods(method_node)
          return Node.new(value: method_node, children: []) if called_methods.empty?

          children =
            called_methods.filter_map do |called_method|
              method_call_tree(called_method, seen_method_calls + [method_name])
            end

          Node.new(value: method_node, children: children)
        end

        def find_called_methods(method_node)
          called_methods =
            method_calls(method_node).filter_map { |method_call| @methods[method_call] }

          @called_methods ||= Set.new(@callback_methods)
          @called_methods += called_methods

          called_methods
        end

        def build_ordered_private_methods
          @ordered_private_methods = ordered_private_methods(@method_call_tree)
        end

        def ordered_private_methods(node)
          current_methods = []
          ast_node = node.value
          if !should_ignore?(ast_node)
            current_methods << ast_node.method_name
          end

          child_methods = node.children.flat_map { |child| ordered_private_methods(child) }

          common_methods = child_methods.tally.select { |_, size| size > 1 }.keys
          unique_methods = child_methods - common_methods

          (current_methods + unique_methods + common_methods).compact.uniq
        end

        def should_ignore?(ast_node)
          ast_node.nil? || ignore_visibility?(node_visibility(ast_node)) ||
            !@called_methods.include?(ast_node)
        end

        def build_private_methods
          @private_methods = @methods.keys.intersection(@ordered_private_methods)
        end

        def verify_private_methods_order
          @ordered_private_methods.each_with_index do |ordered_method, ordered_index|
            index = @private_methods.index(ordered_method)

            add_method_offense(ordered_method, ordered_index) && return if index != ordered_index
          end
        end

        def add_method_offense(method_name, method_index)
          method = @methods[method_name]
          previous_method =
            if method_index > 0
              previous_method_name = @ordered_private_methods[method_index - 1]
              @methods[previous_method_name]
            else
              @private_node
            end

          message = format(MSG, previous: previous_method.method_name, after: method_name)

          add_offense(method, message: message) do |corrector|
            autocorrect(corrector, method, previous_method)
          end
        end

        def autocorrect(corrector, method, previous_method)
          previous_method_range = source_range_with_comment(previous_method)
          if buffer.source[previous_method_range.end_pos + 1] == "\n"
            previous_method_range = previous_method_range.adjust(end_pos: 1)
          end

          method_range = source_range_with_signature(method)
          if buffer.source[method_range.begin_pos - 1] == "\n"
            method_range = method_range.adjust(end_pos: 1)
          end

          corrector.insert_after(previous_method_range, method_range.source)
          corrector.remove(method_range)
        end

        def source_range_with_signature(method)
          previous_node = method.left_sibling
          begin_node = sorbet_signature?(previous_node) ? previous_node : method

          begin_pos = begin_pos_with_comment(begin_node)
          end_pos = end_position_for(method)

          Parser::Source::Range.new(buffer, begin_pos, end_pos)
        end

        def sorbet_signature?(node)
          node && node.method_name == :sig && node.type == :block
        end
      end
    end
  end
end
