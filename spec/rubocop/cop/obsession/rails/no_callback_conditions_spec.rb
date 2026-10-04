describe RuboCop::Cop::Obsession::Rails::NoCallbackConditions, :config do
  context 'when callback has a condition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        after_update_commit :crawl_rss, if: :rss_changed?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid condition in callback declaration, move it inside the callback method instead.

        def crawl_rss
          crawl
        end
      RUBY
    end
  end

  context 'when callback does not have a condition' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        after_update_commit :crawl_rss

        def crawl_rss
          return if !rss_changed?
          crawl
        end
      RUBY
    end
  end

  context 'when validation has a condition' do
    it 'does not register an offense' do
      expect_no_offenses('validates :name, presence: true, if: :name_required?')
    end
  end

  context 'when around callback has a condition' do
    it 'does not register an offense' do
      expect_no_offenses('around_save :wrap_save, if: :audit_changes?')
    end
  end
end
