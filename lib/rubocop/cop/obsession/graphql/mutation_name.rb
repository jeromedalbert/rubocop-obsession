# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Graphql
        # This cop checks for mutation names that do not start with a verb.
        #
        # Mutation names should start with a verb, because mutations are actions,
        # and actions are best described with verbs.
        #
        # @example
        #
        #   # bad
        #   module Mutations
        #     class Event < Base
        #     end
        #   end
        #
        #   # good
        #   module Mutations
        #     class TrackEvent < Base
        #     end
        #   end
        class MutationName < Cop
          include Helpers

          MSG = 'Mutation name should start with a verb.'

          def on_class(class_node)
            class_name = class_node.identifier.source
            class_name_first_word = class_name.underscore.split('_').first

            add_offense(class_node) if !verb?(class_name_first_word)
          end
        end
      end
    end
  end
end
