describe RuboCop::Cop::Obsession::Graphql::MutationName, :config do
  context 'when mutation name does not start with a verb' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        module Mutations
          class Event < Base
          ^^^^^^^^^^^^^^^^^^ Mutation name should start with a verb.
          end
        end
      RUBY
    end
  end

  context 'when mutation name starts with a verb' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        module Mutations
          class TrackEvent < Base
          end
        end
      RUBY
    end
  end
end
