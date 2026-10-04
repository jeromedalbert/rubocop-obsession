describe RuboCop::Cop::Obsession::Rails::SafetyAssuredComment, :config do
  context 'when `safety_assured` has no comment' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          safety_assured { remove_column :blog_posts, :source_url }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `# Safe because <reason>` comment above safety_assured. An invalid reason may bring the site down.
        end
      RUBY
    end
  end

  context 'when `safety_assured` has a comment that is too short' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          # Safe because I say so
          safety_assured { remove_column :blog_posts, :source_url }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `# Safe because <reason>` comment above safety_assured. An invalid reason may bring the site down.
        end
      RUBY
    end
  end

  context 'when `safety_assured` has a valid comment' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          # Safe because this column was ignored with self.ignored_columns in PR #1234
          safety_assured { remove_column :blog_posts, :source_url }
        end
      RUBY
    end
  end
end
