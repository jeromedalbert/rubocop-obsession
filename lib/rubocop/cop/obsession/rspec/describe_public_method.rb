# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rspec
        # This cop checks for `describe` blocks that test private methods.
        #
        # If you are doing black box unit testing, it means that you are only
        # interested in testing external behavior, a.k.a public interface,
        # a.k.a public methods. Private methods are considered implementation
        # details and are not directly tested.
        #
        # If you need to test a Rails callback, test it indirectly through its
        # corresponding Rails public method, e.g. #create, #save, etc.
        #
        # @example
        #
        #   class Comment < ApplicationRecord
        #     after_create_commit :notify_users
        #
        #     private
        #
        #     def notify_users
        #       ...
        #     end
        #   end
        #
        #   # bad
        #   describe '#notify_users' do
        #     ...
        #   end
        #
        #   # good
        #   describe '#create' do
        #     it 'notifies users' do
        #       ...
        #     end
        #   end
        class DescribePublicMethod < Cop
          MSG = 'Only test public methods.'

          def_node_matcher :on_context_method, <<-PATTERN
            (block (send nil? :describe (str $#method_name?)) ...)
          PATTERN

          def_node_search :class_nodes, <<~PATTERN
            (class ...)
          PATTERN

          def_node_matcher :private_section?, <<~PATTERN
            (send nil? {:private :protected})
          PATTERN

          def on_block(node)
            on_context_method(node) do |method_name|
              method_name = method_name.sub('#', '').to_sym
              add_offense(node) if private_methods.include?(method_name)
            end
          end

          private

          def method_name?(description)
            description.start_with?('#')
          end

          def private_methods
            return @private_methods if @private_methods
            @private_methods = []

            if File.exist?(tested_file_path)
              node = parse_file(tested_file_path)
              @private_methods = find_private_methods(class_nodes(node).first)
            end

            @private_methods
          end

          def tested_file_path
            return @tested_file_path if @tested_file_path

            spec_path = processed_source.file_path.sub(Dir.pwd, '')
            file_path =
              if spec_path.include?('/lib/')
                spec_path.sub('/spec/lib/', '/lib/')
              else
                spec_path.sub('/spec/', '/app/')
              end
            file_path = file_path.sub('_spec.rb', '.rb')
            file_path = File.join(Dir.pwd, file_path)

            @tested_file_path = file_path
          end

          def parse_file(file_path)
            parser_class = ::Parser.const_get(:"Ruby#{target_ruby_version.to_s.sub('.', '')}")
            parser = parser_class.new(RuboCop::AST::Builder.new)

            buffer = Parser::Source::Buffer.new(file_path, 1)
            buffer.source = File.read(file_path)

            parser.parse(buffer)
          end

          def find_private_methods(class_node)
            return [] if class_node&.body&.type != :begin
            private_methods = []
            private_section_found = false

            class_node.body.children.each do |child|
              if private_section?(child)
                private_section_found = true
              elsif child.type == :def && private_section_found
                private_methods << child.method_name
              end
            end

            private_methods
          end
        end
      end
    end
  end
end
