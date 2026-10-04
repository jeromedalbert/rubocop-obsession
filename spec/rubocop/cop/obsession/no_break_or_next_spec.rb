describe RuboCop::Cop::Obsession::NoBreakOrNext, :config do
  context 'when loop is big' do
    it 'registers an offense when loop has `next`' do
      expect_offense(<<~RUBY)
        github_teams.each do |github_team|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `break`/`next` in big loop, decompose into private method or rethink loop.
          next if github_team['size'] == 0
          team = @company.teams.find_or_initialize_by(github_team['id'])

          team.update!(
            name: github_team['name'],
            description: github_team['description'],
            owner: @company,
          )
        end
      RUBY
    end

    it 'registers an offense when loop has `break`' do
      expect_offense(<<~RUBY)
        github_teams.each do |github_team|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `break`/`next` in big loop, decompose into private method or rethink loop.
          break if github_team['size'] == 0
          team = @company.teams.find_or_initialize_by(github_team['id'])

          team.update!(
            name: github_team['name'],
            description: github_team['description'],
            owner: @company,
          )
        end
      RUBY
    end
  end

  context 'when loop is small' do
    it 'registers an offense when loop has `next`' do
      expect_offense(<<~RUBY)
        def highlight
          blog_posts.each do |blog_post|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `next` in loop, use conditions or rethink loop.
            next if !blog_post.published?

            self.highlighted = true
          end
        end
      RUBY
    end

    it 'does not register an offense when loop has `break`' do
      expect_no_offenses(<<~RUBY)
        def highlight
          blog_posts.each do |blog_post|
            break if !blog_post.published?

            self.highlighted = true
          end
        end
      RUBY
    end
  end

  context 'when loop has no `next` or `break`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def highlight
          blog_posts.each do |blog_post|
            if blog_post.published?
              self.highlighted = true
            end
          end
        end
      RUBY
    end
  end
end
