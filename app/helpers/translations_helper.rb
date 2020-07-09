module TranslationsHelper
	def paragraph_to_br(str)
		str = str[3..str.length] if str[0..2] == '<p>'
		return str.gsub('<br>', '').gsub('<p>', '<br>').gsub('</p>', '')
	end

	def html_safe_translations(translation)
		if translation
			return translation.html_safe
		else
			return I18n.translate('translations.errors.missing_translation_for_item')
		end
	end

	def etcetera(str)
    return I18n.translate('translations.add_etc', str: str)
	end
end
