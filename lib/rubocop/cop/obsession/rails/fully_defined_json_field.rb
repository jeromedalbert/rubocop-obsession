# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for json(b) fields that are not fully defined with
        # defaults or comments.
        #
        # - json(b) fields should have a default value like {} or [] so code can
        #   do my_field['field'] or my_field.first without fear that my_field is
        #   nil.
        # - It is impossible to know the structure of a json(b) field just by
        #   reading the schema, because json(b) is an unstructured type. That's why
        #   an "Example: ..." Postgres comment should always be present when
        #   defining the field.
        #
        # @example
        #
        #   # bad
        #   add_column :languages, :items, :jsonb
        #
        #   # good
        #   add_column :languages,
        #              :items,
        #              :jsonb,
        #              default: [],
        #              comment: "Example: [{ 'name': 'ruby' }, { 'name': 'python' }]"
        class FullyDefinedJsonField < Base
          def_node_matcher :json_field?, <<~PATTERN
            (send nil? :add_column _ _ (sym {:json :jsonb}) ...)
          PATTERN

          def_node_matcher :has_default?, <<~PATTERN
            (hash <(pair (sym :default) ...) ...>)
          PATTERN

          def_node_matcher :has_comment_with_example?, <<~PATTERN
            (hash <
              (pair
                (sym :comment)
                `{
                  (str /^Example: [\\[\\{].{4,}[\\]\\}]/) |
                  (dstr (str /^Example: [\\[\\{]/) ... (str /[\\]\\}]/) )
                }
              )
              ...
            >)
          PATTERN

          def on_send(node)
            return if !json_field?(node)
            options_node = node.children[5]

            if !has_default?(options_node)
              add_offense(node, message: 'Add default value of {} or []')
            end

            if !has_comment_with_example?(options_node)
              add_offense(
                node,
                message:
                  'Add `comment: "Example: <example>"` option with an example array or hash value'
              )
            end
          end
        end
      end
    end
  end
end
