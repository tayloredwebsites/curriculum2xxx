module TranslationsHelper
	def paragraph_to_br(str)
		str = str[3..str.length] if str[0..2] == '<p>'
		return str.gsub('<p>', '<br>').gsub('</p>', '')
	end
end
