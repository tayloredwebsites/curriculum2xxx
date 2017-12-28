class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # to do - get these from translations table
  SAVE_STATUS = ['No Change', 'Added', 'Updated', 'Error']
  SAVE_STATUS_NO_CHANGE = 0
  SAVE_STATUS_ADDED = 1
  SAVE_STATUS_UPDATED = 2
  SAVE_STATUS_ERROR = 3
  SAVE_STATUS_SKIP = 4

  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  OTC_TREE_TYPE_ID = 1
  OTC_TREE_TYPE_CODE = 'OTC.'
  OTC_VERSION_ID = 1
  OTC_VERSION_CODE = 'v01.'
  OTC_TRANSLATION_START = 'OTC.v01.'

  OTC_TREE_LABELS = ['Area', 'Component', 'Outcome', 'Indicator']
  OTC_TREE_AREA = 0
  OTC_TREE_COMPONENT = 1
  OTC_TREE_OUTCOME = 2
  OTC_TREE_INDICATOR = 3

  UPLOAD_RPT_EXTRA_LABELS = ['Code','Description','Status Message']
  UPLOAD_RPT_CODE = 0
  UPLOAD_RPT_NAME = 1
  UPLOAD_RPT_MESSAGE = 2

end
