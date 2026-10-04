describe RuboCop::Cop::Obsession::NoTodos, :config do
  %w[TODO FIXME OPTIMIZE HACK].each do |keyword|
    it "registers an offense when there is a #{keyword} comment" do
      comment = "# #{keyword}: remove this method when we ship the new signup flow"

      expect_offense(<<~RUBY)
        #{comment}
        #{'^' * comment.length} Avoid TODO comment, create a task in your project management tool instead.
        def my_method
          some_code
        end
      RUBY
    end
  end

  it 'registers an offense when TODO comment is inline' do
    expect_offense(<<~RUBY)
      my_method # TODO: remove this method
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid TODO comment, create a task in your project management tool instead.
    RUBY
  end

  it 'does not register an offense when there is no TODO comment' do
    expect_no_offenses(<<~RUBY)
      def my_method
        some_code
      end
    RUBY
  end
end
