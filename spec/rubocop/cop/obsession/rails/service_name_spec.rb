describe RuboCop::Cop::Obsession::Rails::ServiceName, :config do
  context 'when class name does not start with a verb' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class BlogPostPopularityJob < ApplicationJob
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Service or Job name should start with a verb.
          def perform
          end
        end
      RUBY
    end

    it 'registers an offense when class has a nested namespace' do
      expect_offense(<<~RUBY)
        module Scheduled
          class BlogPostPopularityJob < ApplicationJob
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Service or Job name should start with a verb.
            def perform
            end
          end
        end
      RUBY
    end

    it 'registers an offense when class has a compact namespace' do
      expect_offense(<<~RUBY)
        class Scheduled::BlogPostPopularityJob < ApplicationJob
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Service or Job name should start with a verb.
          def perform
          end
        end
      RUBY
    end

    it 'does not register an offense when class has more than 1 public method' do
      expect_no_offenses(<<~RUBY)
        class BlogPostImporter < ApplicationJob
          def import_one_post
          end

          def import_all_posts
          end
        end
      RUBY
    end
  end

  context 'when class name starts with a verb' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class UpdateBlogPostPopularityJob < ApplicationJob
          def perform
          end
        end
      RUBY
    end

    it 'does not register an offense when class has a nested namespace' do
      expect_no_offenses(<<~RUBY)
        module Scheduled
          class UpdateBlogPostPopularityJob < ApplicationJob
            def perform
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when class has a compact namespace' do
      expect_no_offenses(<<~RUBY)
        class Scheduled::UpdateBlogPostPopularityJob < ApplicationJob
          def perform
          end
        end
      RUBY
    end
  end
end
