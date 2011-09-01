guard 'test' do
  watch(%r{^lib/([^/]+/)*(.+)\.rb$}) { |m| "test/unit/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/.+test_.+\.rb$})
  watch('test/test_helper.rb')  { "test" }
end
