Translation.class_eval do

  DEFAULT_LOCALE = 'bs'

  def self.find_translation(locale, code, checkDefault = true)
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
          return nil, BaseRec::REC_ERROR, "Missing translation for #{code}"
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
    rec, status, message = self.find_translation(locale, code, false)
    if rec.blank?
      # no matching record, create it
      rec = Translation.create(locale: locale, key: code, value: val)
      if rec.errors.count > 0
        return nil, BaseRec::REC_ERROR, "ERROR creating translation for #{code} to: #{val}"
      end
      return rec, BaseRec::REC_ADDED, ''
    else
      # found existing record, check if value changed
      if rec.value != val
        # update and retun changed record
        rec.value = val
        rec.save
        if rec.errors.count > 0
          return nil, BaseRec::REC_ERROR, "ERROR updating translation for #{code} to #{val}"
        end
        return rec, BaseRec::REC_UPDATED, ''
      else
        return rec, BaseRec::REC_NO_CHANGE, ''
      end # if rec.val != val
    end # rec.present
  end

end
