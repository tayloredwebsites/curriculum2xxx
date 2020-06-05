class Version < BaseRec
	scope :active, -> { where(:active => true) }
end
