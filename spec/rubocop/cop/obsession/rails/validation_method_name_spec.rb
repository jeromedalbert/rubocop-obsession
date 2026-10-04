describe RuboCop::Cop::Obsession::Rails::ValidationMethodName, :config do
  context 'when validation method does not start with `validate_`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        validate :at_least_one_admin
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefix custom validation method with validate_
      RUBY
    end
  end

  context 'when validation method starts with `validate_`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        validate :validate_at_least_one_admin
      RUBY
    end
  end
end
