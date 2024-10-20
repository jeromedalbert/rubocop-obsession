if defined?(RuboCop::RSpec)
  module RuboCop
    module Cop
      module Obsession
        module Rspec
          # Same as RSpec/EmptyLineAfterFinalLet, but allows `let` to be followed
          # by `it` with no new line, to allow for this style of spec:
          #
          # @example
          #
          #   describe '#domain' do
          #     context do
          #       let(:url) { Url.new('http://www.some-site.com/some-page') }
          #       it { expect(url.domain).to eq 'some-site.com' }
          #     end
          #
          #     context do
          #       let(:url) { Url.new('some-site.com') }
          #       it { expect(url.domain).to eq 'some-site.com' }
          #     end
          #   end
          class EmptyLineAfterFinalLet < RSpec::EmptyLineAfterFinalLet
            def missing_separating_line(node)
              line = final_end_location(node).line
              line += 1 while comment_line?(processed_source[line])
              return if processed_source[line].blank?
              return if processed_source[line].match?(/\s*it /)

              yield offending_loc(line)
            end
          end
        end
      end
    end
  end
end
