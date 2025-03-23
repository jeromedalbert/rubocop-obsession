# frozen_string_literal: true

require 'lint_roller'

module Rubocop
  module Obsession
    # A plugin that integrates Rubocop Obsession with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-obsession',
          version: VERSION,
          homepage: 'https://github.com/jeromedalbert/rubocop-obsession',
          description: 'A collection of RuboCop cops for enforcing higher-level code concepts.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
