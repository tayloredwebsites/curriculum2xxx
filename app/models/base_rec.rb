class BaseRec < ActiveRecord::Base
  self.abstract_class = true

  # Only used in uploads
  SAVE_CODE_STATUS = ['', 'Code Added', 'Code Updated', 'Code Error']
  REC_NO_CHANGE = 0
  REC_ADDED = 1
  REC_UPDATED = 2
  REC_ERROR = 3

  # only used in uploads and testing
  UPLOAD_STATUS = ['-', 'Upload Started', 'Uploaded', 'Upload Done']
  UPLOAD_PROGRESS_PCT = [0, 33, 67, 100]
  UPLOAD_NOT_UPLOADED = 0
  UPLOAD_TREE_UPLOADING = 1
  UPLOAD_TREE_UPLOADED = 2
  UPLOAD_DONE = 3

  #To Do - check this
  # hard coded variables - must match record 1 in database tables - see db/seeds.rb
  # only used by factorybot. see test/factories/factories.rb
  TREE_TYPE_ID = 1
  TREE_TYPE_CODE = 'TFV'
  VERSION_ID = 1
  VERSION_CODE = 'v01'


  LOCALE_BS = 'bs'
  LOCALE_HR = 'hr'
  LOCALE_SR = 'sr'
  LOCALE_EN = 'en'
  LOCALE_TR = 'tr'
  LOCALE_TR_TR = 'tr_TR'
  VALID_LOCALES = [LOCALE_TR, LOCALE_EN]
  DEFAULT_LOCALE = LOCALE_EN
  BASE_SUBJECTS = [
    'bio', #Biology
    'cap', #Capstones
    'che', #Chemistry
    'edu', #Education
    'eng', #English
    'mat', #Math
    'mec', #Mechanics
    'phy', #Physics
    'sci', #Science
    'ear', #Earth Science
    'geo', #Geology
    'tech', #Technology
  ]


  # only used in uploads
  UPLOAD_RPT_COL = ['Row', 'Unit', 'Chapter', 'Outcome', 'Indicator', 'Code','Desc','StatusMsg']

  # ALL_SECTORS = ['1','2','3','4','5','6','7','8','9','10']

  #name of the log file where runtime issues with data are logged
  DATA_COMPLAINTS_PATH = "#{Rails.root}/log/data_complaints.out"

  DIM_CHANGE_LOG_PATH = "#{Rails.root}/log/dimension_changes.out"

end
