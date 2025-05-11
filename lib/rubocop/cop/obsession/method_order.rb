# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for private/protected methods that are not ordered
      # correctly. It supports autocorrect.
      #
      # Note 1: the order of public methods is not enforced. They can be
      # defined in any order the developer wants, like by order of importance.
      # This is because public methods are usually called outside of the class
      # and often not called within the class at all. If possible though,
      # developers should still try to order their public methods when it makes
      # sense.
      #
      # Note 2: for top to bottom styles, method order cannot be computed for
      # methods called by `send`, metaprogramming, private methods called by
      # superclasses or modules, etc. This cop's suggestions and
      # autocorrections may be slightly off for these cases.
      #
      # Note 3: for simplicity, protected methods do not have to be ordered if
      # there are both a protected section and a private section.
      #
      # @example EnforcedStyle: drill_down (default)
      #   In this style, code should read from top to bottom. More
      #   particularly, methods should be defined in the same order as the
      #   order when they are first mentioned. Put another way, you go to the
      #   bottom of the method call tree before going back up. See examples
      #   below.
      #
      #   This style is similar to the code example provided in the "Reading
      #   Code from Top to Bottom: The Stepdown Rule" chapter from Robert C.
      #   Martin's "Clean Code" book, but diverges from it in that it drills
      #   down to the bottom of the call tree as much as possible.
      #
      #   # bad
      #   class Foo
      #     def perform
      #       return if method_a?
      #       method_b
      #       method_c
      #     end
      #
      #     private
      #
      #     def method_c; ...; end
      #     def method_b; ...; end
      #     def method_a?; ...; end
      #   end
      #
      #   # good
      #   class Foo
      #     def perform
      #       return if method_a?
      #       method_b
      #       method_c
      #     end
      #
      #     private
      #
      #     def method_a?; ...; end
      #     def method_b; ...; end
      #     def method_c; ...; end
      #   end
      #
      #   # bad
      #   class Foo
      #     def perform
      #       method_a
      #       method_b
      #     end
      #
      #     private
      #
      #     def method_a; method_c; end
      #     def method_b; method_c; end
      #     def method_c; ...; end
      #   end
      #
      #   # good
      #   class Foo
      #     def perform
      #       method_a
      #       method_b
      #     end
      #
      #     private
      #
      #     def method_a; method_c; end
      #     def method_c; ...; end
      #     def method_b; method_c; end
      #   end
      #
      # @example EnforcedStyle: step_down
      #   In this style, code should read from top to bottom. More
      #   particularly, common called methods (which tend to have a lower level
      #   of abstraction) are defined after the group of methods that calls
      #   them (these caller methods tend to have a higher level of
      #   abstraction). The idea is to gradually descend one level of
      #   abstraction at a time.
      #
      #   This style adheres more strictly to the code example provided in the
      #   "Reading Code from Top to Bottom: The Stepdown Rule" chapter from
      #   Robert C. Martin's "Clean Code" book.
      #
      #   # bad
      #   class Foo
      #     def perform
      #       method_a
      #       method_b
      #     end
      #
      #     private
      #
      #     def method_a; method_c; end
      #     def method_c; ...; end
      #     def method_b; method_c; end
      #   end
      #
      #   # good
      #   class Foo
      #     def perform
      #       method_a
      #       method_b
      #     end
      #
      #     private
      #
      #     def method_a; method_c; end
      #     def method_b; method_c; end
      #     def method_c; ...; end
      #   end
      #
      # @example EnforcedStyle: alphabetical
      #   In this style, methods are ordered alphabetically. This style is
      #   unambiguous and interpretation-free.
      #
      #   # bad
      #   class Foo
      #     def perform; ...; end
      #
      #     private
      #
      #     def method_c; ...; end
      #     def method_b; ...; end
      #     def method_a; ...; end
      #   end
      #
      #   # good
      #   class Foo
      #     def perform; ...; end
      #
      #     private
      #
      #     def method_a; ...; end
      #     def method_b; ...; end
      #     def method_c; ...; end
      #   end
      class MethodOrder < Base
        include ConfigurableEnforcedStyle
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

        def build_ordered_private_methods
          if style == :alphabetical
            @ordered_private_methods = alphabetically_ordered_private_methods
          else
            build_callback_methods
            build_method_call_tree
            @ordered_private_methods = top_to_bottom_ordered_private_methods(@method_call_tree)
          end
        end

        def alphabetically_ordered_private_methods
          @methods
            .values
            .uniq
            .reject { |method| ignore_visibility?(node_visibility(method)) }
            .map(&:method_name)
            .sort
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

        def top_to_bottom_ordered_private_methods(node)
          ast_node = node.value
          method_name = should_ignore?(ast_node) ? nil : ast_node.method_name
          next_names =
            node.children.flat_map { |child| top_to_bottom_ordered_private_methods(child) }

          common_methods =
            (style == :drill_down) ? [] : next_names.tally.select { |_, size| size > 1 }.keys
          unique_methods = next_names - common_methods

          ([method_name] + unique_methods + common_methods).compact.uniq
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
          node&.respond_to?(:method_name) && node.method_name == :sig && node.type == :block
        end
      end
    end
  end
end
