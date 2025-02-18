RSpec.describe RuboCop::Cop::Obsession::MethodOrder, :config do
  it 'expects the order of private methods to match the order of their first call' do
    expect_offense(<<~RUBY)
      class Foo
        def perform
          method_a
          method_b
        end

      private

        def method_b; 2; end
        def method_a; 4; end
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

        def method_a; 4; end
        def method_b; 2; end
      end
    RUBY
  end

  it 'expects methods called by multiple methods to be below all of them' do
    expect_offense(<<~RUBY)
      class Foo
        def perform
          method_a
          method_b
        end

      private

        def method_a; method_c; end
        def method_c; 4; end
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
        def method_c; 4; end
      end
    RUBY
  end
end
