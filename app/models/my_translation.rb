class MyTranslation < I18n::Backend::ActiveRecord::Translation
  # see config/initializers/translation_patch.rb

  # does not seem to be working ?
  # belongs_to :tree
end
