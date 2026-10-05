describe RuboCop::Cop::Obsession::MethodOrder, :config do
  context 'when enforced style is drill_down' do
    let(:cop_config) { { 'EnforcedStyle' => 'drill_down' } }

    context 'when private methods are not ordered from top to bottom' do
      it 'registers an offense' do
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
    end

    context 'when private methods are ordered from top to bottom' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
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
    end

    context 'when a shared method is not below the first caller' do
      it 'registers an offense' do
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

    context 'when callback methods are not ordered from top to bottom' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class Foo
            before_validation :method_a
            after_save :method_b

            def my_public_method
              method_c
            end

            private

            def method_c; end
            def method_b; end
            def method_a; end
            ^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            before_validation :method_a
            after_save :method_b

            def my_public_method
              method_c
            end

            private

            def method_a; end
            def method_b; end
            def method_c; end
          end
        RUBY
      end
    end

    context 'when module private methods are not ordered from top to bottom' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          module Foo
            def my_public_method
              method_a
            end

            private

            def method_b; end
            def method_a; method_b; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
          end
        RUBY

        expect_correction(<<~RUBY)
          module Foo
            def my_public_method
              method_a
            end

            private

            def method_a; method_b; end
            def method_b; end
          end
        RUBY
      end
    end

    context 'when module callback methods are not ordered from top to bottom' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          module Foo
            extend ActiveSupport::Concern

            included do
              before_validation :method_a
            end

            def self.included(base)
              base.class_eval { before_validation :method_b }
              base.before_validation :method_c
            end

            def my_public_method; method_d; end

            private

            def method_d; end
            def method_c; end
            def method_b; end
            def method_a; end
            ^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
          end
        RUBY

        expect_correction(<<~RUBY)
          module Foo
            extend ActiveSupport::Concern

            included do
              before_validation :method_a
            end

            def self.included(base)
              base.class_eval { before_validation :method_b }
              base.before_validation :method_c
            end

            def my_public_method; method_d; end

            private

            def method_a; end
            def method_b; end
            def method_c; end
            def method_d; end
          end
        RUBY
      end
    end
  end

  context 'when enforced style is step_down' do
    let(:cop_config) { { 'EnforcedStyle' => 'step_down' } }

    context 'when a shared method is not below all callers' do
      it 'registers an offense' do
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

    context 'when a shared method is below all callers' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
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
  end

  context 'when enforced style is alphabetical' do
    let(:cop_config) { { 'EnforcedStyle' => 'alphabetical' } }

    context 'when private methods are not ordered alphabetically' do
      it 'registers an offense' do
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

    context 'when private methods are ordered alphabetically' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
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

    context 'when module methods are not ordered alphabetically' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          module Foo
            def my_public_method; end

            private

            def method_b; end
            def method_a; end
            ^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
          end
        RUBY

        expect_correction(<<~RUBY)
          module Foo
            def my_public_method; end

            private

            def method_a; end
            def method_b; end
          end
        RUBY
      end
    end
  end

  it 'autocorrects methods with Sorbet signatures' do
    expect_offense(<<~RUBY)
      class Foo
        def perform
          method_a
          method_b
        end

        private

        sig { void }
        def method_b; end

        sig { returns(Integer) }
        def method_a; 1; end
        ^^^^^^^^^^^^^^^^^^^^ Method `method_a` should appear below `private`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def perform
          method_a
          method_b
        end

        private

        sig { returns(Integer) }
        def method_a; 1; end

        sig { void }
        def method_b; end
      end
    RUBY
  end
end
