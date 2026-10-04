describe RuboCop::Cop::Obsession::Rspec::EmptyLineAfterFinalLet, :config do
  let(:other_cops) do
    {
      'RSpec' => {
        'Language' => {
          'ExampleGroups' => {
            'Regular' => %w[describe context],
            'Focused' => [],
            'Skipped' => []
          },
          'Helpers' => %w[let]
        }
      }
    }
  end

  context 'when `let` is followed by `it`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe Url do
          describe '#domain' do
            context do
              let(:url) { Url.new('http://www.some-site.com/some-page') }
              it { expect(url.domain).to eq 'some-site.com' }
            end

            context do
              let(:url) { Url.new('some-site.com') }
              it { expect(url.domain).to eq 'some-site.com' }
            end
          end
        end
      RUBY
    end
  end
end
