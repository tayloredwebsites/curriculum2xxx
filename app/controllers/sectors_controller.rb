class SectorsController < ApplicationController

  def index

    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all.order(:code)
    @sectors = Sector.all
    @sector = Sector.new

    # get translation from hash of pre-cached translations.
    name_keys = @sectors.pluck(:name_key)
    # to do - add translations for grade bands and sectors into translations table
    name_keys.concat(@subjects.map {|s| "subject.#{s.code}.name"} )
    name_keys.concat(@gbs.map { |g| "grade_band.#{g.code}.name"} )
    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: name_keys).all
    translations.each do |t|
      @translations[t.key] = t.value
    end

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
    @gradeBandOptions = helpers.gradeBandsOptions(@grade_band_id)
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
      name_keys= @trees.pluck(:name_key)
      translations = Translation.where(locale: @locale_code, key: name_keys).all
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
    rptRows << [sector.code, '', @translations[sector.name_key]]
    # filter out records when pulling from the join
    if @grade_band_id.present? && @subject_id.present?
      sector.trees.where(grade_band_id: @grade_band_id, subject_id: @subject_id ).each do |t|
        rptRows << ['', t.code, @translations[t.name_key]] if t.indicator.present?
      end
    elsif @grade_band_id.present?
      sector.trees.where(grade_band_id: @grade_band_id).each do |t|
        rptRows << ['', t.code, @translations[t.name_key]] if t.indicator.present?
      end
    elsif @subject_id.present?
      sector.trees.where(subject_id: @subject_id ).each do |t|
        rptRows << ['', t.code, @translations[t.name_key]] if t.indicator.present?
      end
    else
      sector.trees.each do |t|
        rptRows << ['', t.code, @translations[t.name_key]] if t.indicator.present?
      end
    end
    return  rptRows
  end



end
