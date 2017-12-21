class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # to do - get these from translations table
  SAVE_STATUS = ['No Change', 'Added', 'Updated', 'Error']
  SAVE_STATUS_NO_CHANGE = 0
  SAVE_STATUS_ADDED = 1
  SAVE_STATUS_UPDATED = 2
  SAVE_STATUS_ERROR = 3

end
