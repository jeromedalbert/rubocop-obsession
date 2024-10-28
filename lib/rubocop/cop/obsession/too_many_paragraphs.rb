# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for methods with too many paragraphs.
      #
      # You should organize your method code into 2 to 3 paragraphs maximum.
      # The 3 possible paragraphs themes could be: initialization, action,
      # and result. Shape your paragraph according to those themes. Spec code
      # should also be organized into 2 to 3 paragraphs
      # (initialization/action/result or given/when/then paragraphs).
      #
      # After organizing your paragraphs, if they are too long or dense, it
      # could be a sign that they should be broken into smaller methods.
      #
      # @example
      #
      #   # bad
      #   def set_seo_content
      #     return if seo_content.present?
      #
      #     template = SeoTemplate.find_by(template_type: 'BlogPost')
      #
      #     return if template.blank?
      #
      #     self.seo_content = build_seo_content(seo_template: template, slug: slug)
      #
      #     Rails.logger.info('Content has been set')
      #   end
      #
      #   # good
      #   def set_seo_content
      #     return if seo_content.present?
      #     template = SeoTemplate.find_by(template_type: 'BlogPost')
      #     return if template.blank?
      #
      #     self.seo_content = build_seo_content(seo_template: template, slug: slug)
      #
      #     Rails.logger.info('Content has been set')
      #   end
      class TooManyParagraphs < Base
        MSG = 'Organize method into 2 to 3 paragraphs (init, action, result).'
        MAX_PARAGRAPHS = 3

        def on_def(node)
          lines = processed_source.lines[node.first_line..(node.last_line - 2)]
          blank_lines_count = lines.count(&:blank?)

          add_offense(node) if blank_lines_count >= MAX_PARAGRAPHS
        end
        alias_method :on_defs, :on_def
      end
    end
  end
end
