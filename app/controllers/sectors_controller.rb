class SectorsController < ApplicationController

  before_action :getLocaleCode

  def index

    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @sectors = Sector.all
    @sector = Sector.new

    # get translation from hash of pre-cached translations.
    translation_keys = @sectors.pluck(:translation_key)
    # to do - add translations for grade bands and sectors into translations table
    translation_keys.concat(@subjects.map {|s| "subject.#{s.code}.name"} )
    translation_keys.concat(@gbs.map { |g| "grade_band.#{g.code}.name"} )
    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: translation_keys).all
    translations.each do |t|
      @translations[t.key] = t.value
    end

    @tree = Tree.new()
    if params[:tree].present?
      @subject_id = params[:tree][:subject_id].present? ? params[:tree][:subject_id] : nil
      @grade_band_id = params[:tree][:grade_band_id].present? ? params[:tree][:grade_band_id] : nil
      @sector_id = params[:tree][:sector_id].present? ? params[:tree][:sector_id] : nil
    end
    @subjectOptions, @selectedSubjectName = helpers.subjectsOptions(@subject_id)
    @gradeBandOptions, @selectedGradeBandName = helpers.gradeBandsOptions(@grade_band_id)
    @sectorsOptions, @selectedSectorName = helpers.sectorsOptions(@sector_id)

    @rptRows = []
    if params[:tree].present?
      listing = Tree.where(
        tree_type_id: @treeTypeRec.id,
        version_id: @versionRec.id
      )
      listing = listing.where(subject_id: @subject_id) if @subject_id.present?
      listing = listing.where(grade_band_id: @grade_band_id) if @grade_band_id.present?
      # get all curriculum items for this sector
      if @sector_id.present?
        @sector = Sector.find(@sector_id)
        sectorTreeIds = @sector.trees.pluck(:tree_id)
        # filter tree listing to only include ones in selected sector
        listing = listing.where(id: sectorTreeIds)
      else
        # assume all tree items, not worth adding ten filters, will probably end up with all anyway
      end

      # listing = listing.is_indicator
      @trees = listing.all

      # to do - filter out all but indicator records.
      # note: indicator records have code of length 4, tricky to do (must be done in sql, and not a sql standard).
      # consider adding length/depth field to record (denormalized for convenience)

      # translation 'includes' not working due to Translations table belonging to I18n Active record gem.
      # note: Active Record had problems with placeholder conditions in join clause.
      # Left join not working, since translation table is owned by gem, and am having trouble inheriting it into MyTranslations.
      # possibly create own Translation model to allow includes, or join I18n Translation table somehow
      # Current solution: get translation from hash of pre-cached translations.
      translation_keys= @trees.pluck(:translation_key)
      translations = Translation.where(locale: @locale_code, key: translation_keys).all
      translations.each do |t|
        @translations[t.key] = t.value
      end

      # to do - allow for top level sort by subject
      # to do - allow for sort of grade band above indicator
      if @sector_id.present?
        @sector = Sector.find(@sector_id)
        sectorTreeIds = @sector.trees.pluck(:tree_id)
        # filter tree listing to only include ones in selected sector
        @rptRows = outputRowsForSector(@sector)
      else
        # filter tree to list tree items by sector
        @rptRows = []
        @sectors.each do |s|
          @rptRows.concat(outputRowsForSector(s))
        end
      end
    end # if params[:tree].present? (generating report)
  end

  private

  def outputRowsForSector(sector)
    rptRows = []
    rptRows << [sector.code, '', @translations[sector.translation_key]]
    # filter out records when pulling from the join
    if @grade_band_id.present? && @subject_id.present?
      sector.trees.where(grade_band_id: @grade_band_id, subject_id: @subject_id ).each do |t|
        rptRows << ['', t.code, @translations[t.translation_key]] if t.indicator.present?
      end
    elsif @grade_band_id.present?
      sector.trees.where(grade_band_id: @grade_band_id).each do |t|
        rptRows << ['', t.code, @translations[t.translation_key]] if t.indicator.present?
      end
    elsif @subject_id.present?
      sector.trees.where(subject_id: @subject_id ).each do |t|
        rptRows << ['', t.code, @translations[t.translation_key]] if t.indicator.present?
      end
    else
      sector.trees.each do |t|
        rptRows << ['', t.code, @translations[t.translation_key]] if t.indicator.present?
      end
    end
    return  rptRows
  end



end
