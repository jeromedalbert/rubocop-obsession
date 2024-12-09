# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      module Rails
        # This cop checks for services whose single public method is not named
        # `perform`.
        #
        # Services and jobs with only one public method should have their method
        # named `perform` for consistency. The choice of `perform` as a name is
        # inspired from ActiveJob and makes it easier to make services and jobs
        # interchangeable.
        #
        # @example
        #
        #   # bad
        #   class ImportCompany
        #     def import
        #       ...
        #     end
        #   end
        #
        #   # bad
        #   class ImportCompany
        #     def execute
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
        class ServicePerformMethod < ServiceName
          extend AutoCorrector

          MSG = 'Single public method of Service should be called `perform`'

          def on_class(class_node)
            public_methods = public_methods(class_node)
            return if public_methods.length != 1
            method = public_methods.first

            if method.method_name != :perform
              add_offense(method) do |corrector|
                corrector.replace(method, method.source.sub(method.method_name.to_s, 'perform'))
              end
            end
          end
        end
      end
    end
  end
end
