# .simplecov

# allow 1 hour between all tests that need to be combined
SimpleCov.merge_timeout 3600

# allow simplecov to be called only once when used in multiple tests
SimpleCov.start 'rails' do
  # any custom configs like groups and filters can be here at a central place
end
