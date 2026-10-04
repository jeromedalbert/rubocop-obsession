describe RuboCop::Cop::Obsession::Rails::CallbackOneMethod, :config do
  context 'when callback declares multiple methods' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        after_create :notify_followers, :send_stats
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Declare only one method per callback definition.
      RUBY
    end
  end

  context 'when callback declares one method' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        after_create :notify_followers
        after_create :send_stats
      RUBY
    end
  end
end
