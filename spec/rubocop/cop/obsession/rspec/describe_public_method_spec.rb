describe RuboCop::Cop::Obsession::Rspec::DescribePublicMethod, :config do
  before do
    allow(cop).to receive(:tested_file_path).and_return(
      File.join(Dir.pwd, 'spec/rubocop/cop/obsession/fixtures/rspec/my_class.rb')
    )
  end

  context 'when `describe` references a private method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe '#my_private_method' do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only test public methods.
        end
      RUBY
    end
  end

  context 'when `describe` references a public method' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe '#my_public_method' do
          it 'does something' do
          end
        end
      RUBY
    end
  end
end
