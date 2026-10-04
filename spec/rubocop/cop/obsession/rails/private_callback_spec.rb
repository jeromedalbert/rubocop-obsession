describe RuboCop::Cop::Obsession::Rails::PrivateCallback, :config do
  context 'when callback method is public' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        before_action :load_blog_post

        def load_blog_post
        ^^^^^^^^^^^^^^^^^^ Make callback method private
          @blog_post = BlogPost.find(params[:id])
        end
      RUBY
    end
  end

  context 'when callback method is private' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        before_action :load_blog_post

        private

        def load_blog_post
          @blog_post = BlogPost.find(params[:id])
        end
      RUBY
    end
  end
end
