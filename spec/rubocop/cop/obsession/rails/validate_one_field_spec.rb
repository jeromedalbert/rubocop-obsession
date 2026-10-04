describe RuboCop::Cop::Obsession::Rails::ValidateOneField, :config do
  context 'when `validates` has multiple fields' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        validates :name, :status, presence: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Validate only one field per line.
      RUBY
    end
  end

  context 'when `validates` has one field' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        validates :name, presence: true
        validates :status, presence: true
      RUBY
    end
  end
end
