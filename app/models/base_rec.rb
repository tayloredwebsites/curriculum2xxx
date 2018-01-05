class BaseRec < ActiveRecord::Base
  self.abstract_class = true

  # to do - get these from translations table
  SAVE_CODE_STATUS = ['', 'Code Added', 'Code Updated', 'Code Error']
  SAVE_TEXT_STATUS = ['', 'Text Added', 'Text Updated', 'Text Error']
  REC_NO_CHANGE = 0
  REC_ADDED = 1
  REC_UPDATED = 2
  REC_ERROR = 3
  REC_SKIP = 4

  # to do - get these from translation table
  UPLOAD_STATUS = ['Not Uploaded', 'Tree Upload Started', 'Tree Uploaded', 'Related to KBE', 'Subjects Relations Started', 'Subjects Related', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 17, 33, 50, 67, 83, 100]
  UPLOAD_NOT_UPLOADED = 0
  UPLOAD_TREE_UPLOADING = 1
  UPLOAD_TREE_UPLOADED = 2
  UPLOAD_KBE_RELATED = 3
  UPLOAD_SUBJ_RELATING = 4
  UPLOAD_SUBJ_RELATED = 5
  UPLOAD_DONE = 6

  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  TREE_TYPE_ID = 1
  TREE_TYPE_CODE = 'OTC'
  VERSION_ID = 1
  VERSION_CODE = 'v01'
  LOCALE_BS = 'bs'
  LOCALE_HR = 'hr'
  LOCALE_SR = 'sr'
  LOCALE_EN = 'en'
  DEFAULT_LOCALE = LOCALE_BS


  TREE_LABELS = ['Area', 'Component', 'Outcome', 'Indicator']
  TREE_AREA = 0
  TREE_COMPONENT = 1
  TREE_OUTCOME = 2
  TREE_INDICATOR = 3

  UPLOAD_RPT_LABELS = ['Area', 'Component', 'Outcome', 'Indicator', 'Code','Description','Status Message']
  # Not to be translated - used in HTML
  UPLOAD_RPT_COL = ['Area', 'Component', 'Outcome', 'Indicator', 'Code','Desc','StatusMsg']
  UPLOAD_RPT_AREA = 0
  UPLOAD_RPT_COMPONENT = 1
  UPLOAD_RPT_OUTCOME = 2
  UPLOAD_RPT_INDICATOR = 3
  UPLOAD_RPT_CODE = 4
  UPLOAD_RPT_DESC = 5
  UPLOAD_RPT_MSG = 6

end
