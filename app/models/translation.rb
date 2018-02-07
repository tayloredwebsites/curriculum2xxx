class Translation < BaseRec

  # to do - add associations

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
            return nil, BaseRec::REC_ERROR, "Missing translation for #{code}"
          end
        else
          return nil, BaseRec::REC_ERROR, "System Error, too many default translations for #{code}"
        end
      else # if checkDefault
        return nil, BaseRec::REC_NO_CHANGE, ''
      end # if checkDefault
    else # if recs.count ...
      raise "System Error, too many translations for locale: #{locale}, code: #{code}"
    end # if recs.count ...
  end

  def self.find_or_update_translation(locale, code, val)
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
          errors << "ERROR creating translation for #{code} to: #{val}"
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
          errors << "ERROR updating translation for #{code} to #{val}"
          return nil, BaseRec::REC_ERROR, errors.to_s
        end
        return rec, BaseRec::REC_UPDATED, ''
      else
        return rec, BaseRec::REC_NO_CHANGE, ''
      end # if rec.val != val
    end # rec.present
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
