describe RuboCop::Cop::Obsession::NoParagraphs, :config do
  context 'when method has more than 5 instructions' do
    it 'registers an offense when method has no blank lines' do
      expect_offense(<<~RUBY)
        def set_seo_content
        ^^^^^^^^^^^^^^^^^^^ Method has many instructions and should be broken up into paragraphs.
          return if slug.blank?
          return if seo_content.present?
          template = SeoTemplate.find_by(template_type: 'BlogPost')
          return if template.blank?
          self.seo_content = build_seo_content(seo_template: template, slug: slug)
          Rails.logger.info('Content has been set')
        end
      RUBY
    end

    it 'does not register an offense when method has blank lines' do
      expect_no_offenses(<<~RUBY)
        def set_seo_content
          return if slug.blank?
          return if seo_content.present?
          template = SeoTemplate.find_by(template_type: 'BlogPost')
          return if template.blank?

          self.seo_content = build_seo_content(seo_template: template, slug: slug)

          Rails.logger.info('Content has been set')
        end
      RUBY
    end
  end

  context 'when method has five instructions or less' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def set_seo_content
          return if slug.blank?
          return if seo_content.present?
          template = SeoTemplate.find_by(template_type: 'BlogPost')
          return if template.blank?
          self.seo_content = build_seo_content(seo_template: template, slug: slug)
        end
      RUBY
    end
  end
end
