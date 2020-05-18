class Translation < BaseRec

  # to do - add associations

  def self.find_translation_name(locale, code, default)
    Rails.logger.debug("*** find_or_update_translation - locale: #{locale.inspect}, code: #{code.inspect}")
    # errors = []
    rec, status, message = self.find_translation(locale, code, false, true)
    ret = default  # return value

    if status == BaseRec::REC_ERROR
      # leave return value to default
      # errors << message
    elsif rec.blank?
      # no matching record, leave return value to default
    else
      # found existing record, set return value
      ret = rec.value
    end # rec.present
    return ret
  end


  # to do - lookup in config.i18n.fallbacks order if not found
  # To Do - Remove the no change error, this is just a lookup by key, no value comparison
  def self.find_translation(locale, code, checkDefault = true, allow_none = false)
    recs = Translation.where(locale: locale, key: code)
    if recs.count == 1
      return recs.first, BaseRec::REC_NO_CHANGE, ''
    elsif recs.count < 1
      if checkDefault
        # lookup the value using the default locale, if not found
        recsD = Translation.where(locale: DEFAULT_LOCALE, key: code)
        if recsD.count == 1
          return recsD.first, BaseRec::REC_NO_CHANGE, ''
        elsif recsD.count < 1
          if allow_none
            return nil, BaseRec::REC_NO_CHANGE, ""
          else
            return nil, BaseRec::REC_ERROR, I18n.t('translations.errors.missing_translations_locale_code', locale: locale, code: code)
          end
        else
          return nil, BaseRec::REC_ERROR, I18n.t('translations.errors.too_many_translations_locale_code', locale: locale, code: code)
        end
      else # if checkDefault
        return nil, BaseRec::REC_NO_CHANGE, ''
      end # if checkDefault
    else # if recs.count ...
      raise I18n.t('translations.errors.too_many_translations_locale_code', locale: locale, code: code)
    end # if recs.count ...
  end

  def self.find_or_update_translation(locale, code, val)
    Rails.logger.debug("*** find_or_update_translation - locale: #{locale.inspect}, code: #{code.inspect}, val: #{val.inspect}")
    errors = []
    rec, status, message = self.find_translation(locale, code, false, true)
    if status == BaseRec::REC_ERROR
      errors << message
    elsif rec.blank?
      # no matching record, create it
      if !VALID_LOCALES.include?(locale)
        err_str = I18n.translate('app.errors.invalid_lang')
        Rails.logger.error("ERROR: #{err_str}")
        errors << err_str
      elsif code.blank?
        err_str = I18n.translate('app.errors.invalid_code', code)
        Rails.logger.error("ERROR: #{err_str}")
        errors << err_str
      else
        rec = Translation.create(locale: locale, key: code, value: val)
        if rec.errors.count > 0
          errors << I18n.t('translations.errors.creating_translations_locale_code', locale: locale, code: code)
          return nil, BaseRec::REC_ERROR, errors.to_s
        end
        return rec, BaseRec::REC_ADDED, ''
      end
    else
      # found existing record, check if value changed
      if rec.value != val
        # update and retun changed record
        rec.value = val
        rec.save
        if rec.errors.count > 0
          errors << I18n.t('translations.errors.updating_translations_locale_code', locale: locale, code: code)
          return nil, BaseRec::REC_ERROR, errors.to_s
        end
        return rec, BaseRec::REC_UPDATED, ''
      else
        return rec, BaseRec::REC_NO_CHANGE, ''
      end # if rec.val != val
    end # rec.present
    # catch fall through errors
    return rec, BaseRec::REC_ERROR, errors.to_s
  end

  def self.translationsByKeys(locale_code, keys)
    ret = Hash.new
    translations = Translation.where(locale: locale_code, key: keys).all
    translations.each do |t|
      ret[t.key] = t.value
    end
    return ret
  end

  def translationsByKeys(locale_code, keys)
    ret = Hash.new
    translations = Translation.where(locale: locale_code, key: keys).all
    translations.each do |t|
      ret[t.key] = t.value
    end
    return ret
  end

end
