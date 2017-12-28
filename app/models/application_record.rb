class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # to do - get these from translations table
  SAVE_STATUS = ['No Change', 'Added', 'Updated', 'Error']
  SAVE_STATUS_NO_CHANGE = 0
  SAVE_STATUS_ADDED = 1
  SAVE_STATUS_UPDATED = 2
  SAVE_STATUS_ERROR = 3
  SAVE_STATUS_SKIP = 4

  # to do - get these from translation table
  UPLOAD_STATUS = ['Not Uploaded', 'Tree Upload Started', 'Tree Uploaded', 'Related to KBE', 'Subjects Relations Started', 'Subjects Related', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 17, 33, 50, 67, 83, 100]
  UPLOAD_STATUS_NOT_UPLOADED = 0
  UPLOAD_STATUS_TREE_UPLOADING = 1
  UPLOAD_STATUS_TREE_UPLOADED = 2
  UPLOAD_STATUS_KBE_RELATED = 3
  UPLOAD_STATUS_SUBJ_RELATING = 4
  UPLOAD_STATUS_SUBJ_RELATED = 5
  UPLOAD_STATUS_DONE = 6

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

  OTC_UPLOAD_RPT_LABELS = ['Area', 'Component', 'Outcome', 'Indicator', 'Code','Description','Status Message']
  # Not to be translated - used in HTML
  OTC_UPLOAD_RPT_COL = ['Area', 'Component', 'Outcome', 'Indicator', 'Code','Desc','StatusMsg']
  OTC_UPLOAD_RPT_AREA = 0
  OTC_UPLOAD_RPT_COMPONENT = 1
  OTC_UPLOAD_RPT_OUTCOME = 2
  OTC_UPLOAD_RPT_INDICATOR = 3
  OTC_UPLOAD_RPT_CODE = 4
  OTC_UPLOAD_RPT_DESC = 5
  OTC_UPLOAD_RPT_MSG = 6

end
