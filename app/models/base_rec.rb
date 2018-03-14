class BaseRec < ActiveRecord::Base
  self.abstract_class = true

  # Only used in uploads
  SAVE_CODE_STATUS = ['', 'Code Added', 'Code Updated', 'Code Error']
  REC_NO_CHANGE = 0
  REC_ADDED = 1
  REC_UPDATED = 2
  REC_ERROR = 3
  REC_SKIP = 4

  # only used in uploads and testing
  UPLOAD_STATUS = ['-', 'OTC Upload Started', 'OTC Uploaded', 'Related to KBE', 'Subjects Relations Started', 'Subjects Related', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 17, 33, 50, 67, 83, 100]
  UPLOAD_NOT_UPLOADED = 0
  UPLOAD_TREE_UPLOADING = 1
  UPLOAD_TREE_UPLOADED = 2
  UPLOAD_SECTOR_RELATED = 3
  UPLOAD_SUBJ_RELATING = 4
  UPLOAD_SUBJ_RELATED = 5
  UPLOAD_DONE = 6

  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  # only used by factorybot. see test/factories/factories.rb
  TREE_TYPE_ID = 1
  TREE_TYPE_CODE = 'OTC'
  VERSION_ID = 1
  VERSION_CODE = 'v01'


  LOCALE_BS = 'bs'
  LOCALE_HR = 'hr'
  LOCALE_SR = 'sr'
  LOCALE_EN = 'en'
  VALID_LOCALES = [LOCALE_BS, LOCALE_HR, LOCALE_SR, LOCALE_EN]
  DEFAULT_LOCALE = LOCALE_BS


  # only used in uploads
  UPLOAD_RPT_COL = ['Row', 'Area', 'Component', 'Outcome', 'Indicator', 'Code','Desc','StatusMsg']

  ALL_SECTORS = ['1','2','3','4','5','6','7','8','9','10']


end
