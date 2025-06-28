# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for services and jobs whose name do not start with a verb.
        #
        # Services and jobs with only one public method should have a name that
        # starts with a verb, because these classes are essentially performing
        # one action, and the best way to describe an action is with a verb.
        #
        # @example
        #   # bad
        #   class Company
        #     def perform
        #       ...
        #     end
        #   end
        #
        #   # good
        #   class ImportCompany
        #     def perform
        #       ...
        #     end
        #   end
        #
        #   # bad
        #   class BlogPostPopularityJob < ApplicationJob
        #     def perform
        #       ...
        #     end
        #   end
        #
        #   # good
        #   class UpdateBlogPostPopularityJob < ApplicationJob
        #     def perform
        #       ...
        #     end
        #   end
        class ServiceName < Base
          include Helpers

          MSG = 'Service or Job name should start with a verb.'
          IGNORED_PUBLIC_METHODS = %i[initialize lock_period].freeze

          def_node_matcher :private_section?, <<~PATTERN
            (send nil? {:private :protected})
          PATTERN

          def on_class(class_node)
            return if public_methods(class_node).length != 1
            class_name = class_node.identifier.source.split('::').last
            class_name_first_word = class_name.underscore.split('_').first

            add_offense(class_node) if !verb?(class_name_first_word)
          end

          private

          def public_methods(class_node)
            return [] if !class_node.body
            public_methods = []

            case class_node.body.type
            when :def
              public_methods << class_node.body
            when :begin
              class_node.body.children.each do |child|
                public_methods << child if child.type == :def
                break if private_section?(child)
              end
            end

            public_methods.reject { |method| IGNORED_PUBLIC_METHODS.include?(method.method_name) }
          end
        end
      end
    end
  end
end
