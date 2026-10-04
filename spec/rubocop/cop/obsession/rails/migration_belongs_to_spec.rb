describe RuboCop::Cop::Obsession::Rails::MigrationBelongsTo, :config do
  context 'when `add_reference` is used' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          add_reference :blog_posts, :user
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use add_belongs_to instead of add_reference
        end
      RUBY
    end
  end

  context 'when `t.references` is used' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def change
          create_table :blog_posts do |t|
            t.references :user, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use t.belongs_to instead of t.references
          end
        end
      RUBY
    end
  end

  context 'when `belongs_to` is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def change
          add_belongs_to :blog_posts, :user

          create_table :comments do |t|
            t.belongs_to :blog_post, null: false
          end
        end
      RUBY
    end
  end
end
