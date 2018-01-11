class Sector < BaseRec

  has_and_belongs_to_many :trees

  def self.sectorCodeFromKbeCode(kbeCode)
    matches = kbeCode.split('.')
    if matches.length == 3 && matches[0] == 'kbe' && matches[2] == 'name'
      return matches[1]
    else
      return ''
    end
  end

end
