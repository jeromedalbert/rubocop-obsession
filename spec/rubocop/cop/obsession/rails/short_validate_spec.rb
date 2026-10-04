describe RuboCop::Cop::Obsession::Rails::ShortValidate, :config do
  context 'when `validate` has `on: %i(create update)`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        validate :validate_url, on: %i[create update]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The `on:` argument is not needed in this validate.
      RUBY
    end
  end

  context 'when `validate` has no `on:` argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        validate :validate_url
      RUBY
    end
  end
end
