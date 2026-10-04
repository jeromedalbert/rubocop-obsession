describe RuboCop::Cop::Obsession::TooManyParagraphs, :config do
  context 'when method has more than 3 paragraphs' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def set_seo_content
        ^^^^^^^^^^^^^^^^^^^ Organize method into 2 to 3 paragraphs (init, action, result).
          return if seo_content.present?

          template = SeoTemplate.find_by(template_type: 'BlogPost')

          return if template.blank?

          self.seo_content = build_seo_content(seo_template: template, slug: slug)

          Rails.logger.info('Content has been set')
        end
      RUBY
    end
  end

  context 'when method has 3 paragraphs or less' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def set_seo_content
          return if seo_content.present?
          template = SeoTemplate.find_by(template_type: 'BlogPost')
          return if template.blank?

          self.seo_content = build_seo_content(seo_template: template, slug: slug)

          Rails.logger.info('Content has been set')
        end
      RUBY
    end
  end
end
