# config/initializers/locale.rb

require 'i18n/backend/active_record'


Translation  = I18n::Backend::ActiveRecord::Translation

## this is used only to load in both yaml tables and database
# if Translation.table_exists?
#   I18n.backend = I18n::Backend::ActiveRecord.new
#
#   I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
#   I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)
#   # I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
#   # I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
#
#   I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
# else

I18n.backend = I18n::Backend::ActiveRecord.new

# end
