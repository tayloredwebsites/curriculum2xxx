module TranslationsHelper
	def paragraph_to_br(str)
		str = str[3..str.length] if str[0..2] == '<p>'
		return str.gsub('<br>', '').gsub('<p>', '<br>').gsub('</p>', '')
	end

	def html_safe_translations(translation, skip_error_message)
		if translation
			return translation.html_safe
		else
			return skip_error_message ? "" : I18n.translate('translations.errors.missing_translation_for_item')
		end
	end

	def etcetera(str)
    return skip_error_message ? "" : I18n.translate('translations.add_etc', str: str)
	end
end
