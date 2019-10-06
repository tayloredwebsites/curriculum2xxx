class SectorsController < ApplicationController
  # Controller for the (10) Sectors of the Knowledge Base

  def index

    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all
    @sectors = Sector.all
    @sector = Sector.new

    # get translation from hash of pre-cached translations.
    # name_keys.concat(@subjects.map {|s| "subject.#{s.code}.name"} )
    # name_keys.concat(@gbs.map { |g| "grade_band.#{g.code}.name"} )

    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    if params[:tree].present?
      @subject_id = params[:tree][:subject_id].present? ? params[:tree][:subject_id] : nil
      @grade_band_id = params[:tree][:grade_band_id].present? ? params[:tree][:grade_band_id] : nil
      @sector_id = params[:tree][:sector_id].present? ? params[:tree][:sector_id] : nil
    end
    @subjectOptions = helpers.subjectsOptions(@subject_id)
    @sectorsOptions = helpers.sectorsOptions(@sector_id, @translations)

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

      # Note: to be able to filter out all but indicator records.
      # indicator records have depth of 4, outcomes have depth of 3.
      # consider adding length/depth field to record (denormalized for convenience)

      # Translations table no longer belonging to I18n Active record gem.
      # note: Active Record had problems with placeholder conditions in join clause.
      # Consider having Translations belong_to trees and sectors.
      # Current solution: get translation from hash of pre-cached translations.
      # to do - allow for top level sort by subject
      # to do - allow for sort of grade band above indicator
      if @sector_id.present?
        @sector = Sector.find(@sector_id)
        name_keys = getNamesForSector(@sector)
        translations = getTranslationsForKeys(name_keys)
        # sectorTreeIds = @sector.trees.pluck(:tree_id)
        # filter tree listing to only include ones in selected sector
        @rptRows = outputRowsForSector(@sector, translations)
      else
        # filter tree to list tree items by sector
        @rptRows = []
        Rails.logger.debug("*** @sectors: #{@sectors.inspect}")
        @sectors.each do |s|
          name_keys = getNamesForSector(s)
          translations = getTranslationsForKeys(name_keys)
          @rptRows.concat(outputRowsForSector(s, translations))
        end
      end
    end # if params[:tree].present? (generating report)

  end

  private

  def getNamesForSector(sector)
    # To Do: filter out subjects and grades not diaplayed
    name_keys = [sector.name_key]
    sector.sector_trees.each do |st|
      name_keys << st.explanation_key
      name_keys << st.tree.name_key
    end
    return name_keys
  end

  def getTranslationsForKeys(keys)
    translations = {}
    translationRecs = Translation.where(locale: @locale_code, key: keys)
    translationRecs.each do |t|
      translations[t.key] = t.value
    end
    return translations
  end


  def outputRowsForSector(sector, translations)
    rptRows = []
    rptRows << [sector.code, '', translations[sector.name_key], '-1', '']
    # filter out records when pulling from the join
    # To Do: put grade band and subject into sector_trees join record to efficiently filter out selected grade or subject
    sector.sector_trees.each do |st|
      if @grade_band_id.present? && st.tree.grade_band_id.to_s != @grade_band_id
      elsif @subject_id.present? && st.tree.subject_id.to_s != @subject_id
      else
        rptRows << [ '', st.tree.codeByLocale(@locale_code), translations[st.tree.name_key], st.tree.id.to_s, translations[st.explanation_key] ]
      end
    end
    return  rptRows
  end



end
