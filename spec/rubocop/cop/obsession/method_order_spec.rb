describe RuboCop::Cop::Obsession::MethodOrder, :config do
  context 'when enforced style is drill_down' do
    let(:cop_config) { { 'EnforcedStyle' => 'drill_down' } }

    it 'expects private methods to be ordered from top to bottom' do
      expect_offense(<<~RUBY)
        class Foo
          def perform
            return if method_a?
            method_b
            method_c
          end

          private

          def method_c; end
          def method_b; end
          def method_a?; end
          ^^^^^^^^^^^^^^^^^^ Method `method_a?` should appear below `private`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def perform
            return if method_a?
            method_b
            method_c
          end

          private

          def method_a?; end
          def method_b; end
          def method_c; end
        end
      RUBY
    end

    it 'expects methods called by multiple methods to be below the first caller' do
      expect_offense(<<~RUBY)
        class Foo
          def perform
            method_a
            method_b
          end

          private

          def method_a; method_c; end
          def method_b; method_c; end
          def method_c; end
          ^^^^^^^^^^^^^^^^^ Method `method_c` should appear below `method_a`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def perform
            method_a
            method_b
          end

          private

          def method_a; method_c; end
          def method_c; end
          def method_b; method_c; end
        end
      RUBY
    end
  end

  context 'when enforced style is step_down' do
    let(:cop_config) { { 'EnforcedStyle' => 'step_down' } }

    it 'expects methods called by multiple methods to be below all of them' do
      expect_offense(<<~RUBY)
        class Foo
          def perform
            method_a
            method_b
          end

          private

          def method_a; method_c; end
          def method_c; end
          def method_b; method_c; end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method `method_b` should appear below `method_a`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def perform
            method_a
            method_b
          end

          private

          def method_a; method_c; end
          def method_b; method_c; end
          def method_c; end
        end
      RUBY
    end
  end

  context 'when enforced style is alphabetical' do
    let(:cop_config) { { 'EnforcedStyle' => 'alphabetical' } }

    it 'expects private methods to be ordered alphabetically' do
      expect_offense(<<~RUBY)
        class Foo
          def perform; end

          private

          def method_c; end
          def method_b; end
          def method_b_a; end
          def method_a; end
          ^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def perform; end

          private

          def method_a; end
          def method_b; end
          def method_b_a; end
          def method_c; end
        end
      RUBY
    end
  end
end
