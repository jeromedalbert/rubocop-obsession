describe RuboCop::Cop::Obsession::Rails::ServicePerformMethod, :config do
  context 'when single public method is not named `perform`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class ImportCompany
          def import
          ^^^^^^^^^^ Single public method of Service should be called `perform`
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class ImportCompany
          def perform
          end
        end
      RUBY
    end
  end

  context 'when single public method is named `perform`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class ImportCompany
          def perform
          end
        end
      RUBY
    end
  end
end
