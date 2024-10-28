# frozen_string_literal: true

module RuboCop
  module Cop
    module Obsession
      # This cop checks for methods with many instructions but no paragraphs.
      #
      # If your method code has many instructions that are not organized into
      # paragraphs, you should break it up into multiple paragraphs to make the
      # code more breathable and readable. The 3 possible paragraphs themes
      # could be: initialization, action, and result.
      #
      # @example
      #
      #   # bad
      #   def set_seo_content
      #     return if slug.blank?
      #     return if seo_content.present?
      #     template = SeoTemplate.find_by(template_type: 'BlogPost')
      #     return if template.blank?
      #     self.seo_content = build_seo_content(seo_template: template, slug: slug)
      #     Rails.logger.info('Content has been set')
      #   end
      #
      #   # good
      #   def set_seo_content
      #     return if slug.blank?
      #     return if seo_content.present?
      #     template = SeoTemplate.find_by(template_type: 'BlogPost')
      #     return if template.blank?
      #
      #     self.seo_content = build_seo_content(seo_template: template, slug: slug)
      #
      #     Rails.logger.info('Content has been set')
      #   end
      class NoParagraphs < Cop
        MSG = 'Method has many instructions and should be broken up into paragraphs.'
        MAX_CONSECUTIVE_INSTRUCTIONS_ALLOWED = 5

        def on_def(node)
          lines = processed_source.lines[node.first_line..(node.last_line - 2)]
          return if lines.any?(&:blank?)
          node_body_type = node&.body&.type
          return if %i[send if or case array hash].include?(node_body_type)
          return if %w[asgn str].any? { |string| node_body_type.to_s.include?(string) }

          too_big =
            case node_body_type
            when :begin, :block, :rescue
              node.body.children.count > MAX_CONSECUTIVE_INSTRUCTIONS_ALLOWED &&
                !node.body.children.all? { |child| child.type.to_s.include?('asgn') }
            else
              lines.count > MAX_CONSECUTIVE_INSTRUCTIONS_ALLOWED
            end

          add_offense(node) if too_big
        end
        alias_method :on_defs, :on_def
      end
    end
  end
end
