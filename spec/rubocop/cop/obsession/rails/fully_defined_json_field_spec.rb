describe RuboCop::Cop::Obsession::Rails::FullyDefinedJsonField, :config do
  context 'when default is missing' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          add_column :languages, :items, :jsonb
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add default value of {} or []
        end
      RUBY
    end
  end

  context 'when comment is missing' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          add_column :languages, :items, :jsonb, default: []
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `comment: "Example: <example>"` option with an example array or hash value
        end
      RUBY
    end
  end

  context 'when there is a default and a comment' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          add_column :languages,
                     :items,
                     :jsonb,
                     default: [],
                     comment: "Example: [{ 'name': 'ruby' }, { 'name': 'python' }]"
        end
      RUBY
    end
  end
end
