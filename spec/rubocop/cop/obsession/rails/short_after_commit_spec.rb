describe RuboCop::Cop::Obsession::Rails::ShortAfterCommit, :config do
  context 'when `after_commit` could be made shorter' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        after_commit :send_email, on: :create
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_create_commit
        after_commit :send_email, on: [:create]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_create_commit
        after_commit :reindex, on: :update
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_update_commit
        after_commit :cleanup, on: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_destroy_commit
        after_commit :send_email, on: [:create, :update]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_save_commit
        after_commit :send_email, on: [:create, :update, :destroy]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorter after_commit with no `on:` argument
      RUBY
    end
  end
end
