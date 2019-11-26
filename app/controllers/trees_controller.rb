class TreesController < ApplicationController

  before_action :find_tree, only: [:show, :show_outcome, :edit, :update]
  before_action :authenticate_user!, only: [:reorder]

  def index
    index_listing
  end

  def index_listing
    # to do - refactor this
    @subjects = {}
    subjIds = {}
    Subject.all.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
    end
    @gbs = GradeBand.all
    # @gbs_upper = GradeBand.where(code: ['9','13'])

    # get subject from tree param or from cookie (app controller getSubjectCode)
    if params[:tree].present? && tree_params[:subject_id].present?
      @subj = subjIds[tree_params[:subject_id]]
      Rails.logger.debug("*** index_listing params ID: #{tree_params[:subject_id]}")
    elsif @subject_code.present? && @subjects[@subject_code].present?
      @subj = @subjects[@subject_code]
      Rails.logger.debug("*** index_listing @subject_code: #{@subject_code.inspect}")
    else
      subjCode, @subj = @subjects.first
      Rails.logger.debug("*** index_listing no match: #{subjCode} #{@subj.inspect}")
    end

    Rails.logger.debug("*** @subject_code: #{@subject_code.inspect}")
    Rails.logger.debug("*** @subj: #{@subj.inspect}")
    Rails.logger.debug("*** @subj.abbr(@locale_code): #{@subj.abbr(@locale_code).inspect}")
    setSubjectCode(@subj.code)

    # get gradeBand from tree param or from cookie (app controller getSubjectCode)
    if params[:tree].present? && tree_params[:grade_band_id] == '0'
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = GradeBand.all.first
    elsif params[:tree].present? && tree_params[:grade_band_id].present?
      @gb = GradeBand.find(tree_params[:grade_band_id])
      @grade_band_code = @gb.code
      Rails.logger.debug("*** index_listing gb params ID: #{tree_params[:grade_band_id]}, code: #{@gb.code}")
    elsif @grade_band_code.present?
      @gb = GradeBand.where(code: @grade_band_code).first
      Rails.logger.debug("*** index_listing @grade_band_code: #{@grade_band_code.inspect}")
      @grade_band_code = @gb.code
    else
      # defaults to all
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = GradeBand.all.first
    end
    setGradeBandCode(@grade_band_code) if @gb
    Rails.logger.debug("*** @grade_band_code: #{@grade_band_code.inspect}")
    Rails.logger.debug("*** @gb: #{@gb.inspect}")

    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    # Note: sort order does matter for sequence of siblings in tree.
    @trees = listing.joins(:grade_band).order("grade_bands.sort_order, trees.sort_order, code").all

    # @tree is used for filtering form
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @tree.subject_id = @subj.id if @subj.present?
    @tree.grade_band_id = @gb.id if @gb.present?

    # Translations table no longer belonging to I18n Active record gem.
    # note: Active Record had problems with placeholder conditions in join clause.
    # Consider having Translations belong_to trees and sectors.
    # Current solution: get translation from hash of pre-cached translations.
    base_keys= @trees.map { |t| "#{t.base_key}.name" }
    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: base_keys)
    translations.each do |t|
      # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
      @translations[t.key] = t.value
    end

    treeHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.name_key]
      areaHash = {}
      depth = tree.depth
      case depth

      when 1
        newHash = {text: "#{I18n.translate('app.labels.grade_band')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # add grade (band) if not there already
        treeHash[tree.codeArrayAt(0)] = newHash if !treeHash[tree.codeArrayAt(0)].present?

      when 2
        newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.codeArrayAt(1)}: #{translation}", id: "#{tree.id}", nodes: {}}
        puts ("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(1)} to area #{tree.codeArrayAt(0)} in treeHash")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)], tree.subCode, newHash)

      when 3
        newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", nodes: {}}
        puts ("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)], tree.subCode, newHash)

      when 4
        newHash = {text: "#{I18n.translate('app.labels.outcome')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)], tree.subCode, newHash)

      when 5
        # # to do - look into refactoring this
        # # check to make sure parent in hash exists.
        # Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
        # Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
        # Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
        newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
        # Rails.logger.debug("indicator newhash: #{newHash.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
          raise I18n.t('trees.errors.missing_component_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
          Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
          raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
        end
        Rails.logger.debug("*** translation: #{translation.inspect}")
        addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)], tree.codeArrayAt(4), newHash)

      else
        raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end
    # convert tree of record codes so that nodes are arrays not hashes for conversion to JSON
    # puts ("+++ treeHash: #{JSON.pretty_generate(treeHash)}")
    otcArrHash = []
    treeHash.each do |key1, area|
      a2 = {text: area[:text], href: "javascript:void(0);"}
      if area[:nodes]
        area[:nodes].each do |key2, comp|
          a3 = {text: comp[:text], href: "javascript:void(0);"}
          comp[:nodes].each do |key3, outc|
            a4 = {text: outc[:text], href: "javascript:void(0);", setting: 'outcome'}
            outc[:nodes].each do |key4, indic|
              a5 = {text: indic[:text], href: tree_path(indic[:id]), setting: 'indicator'}
              a4[:nodes] = [] if a4[:nodes].blank?
              a4[:nodes] << a5
            end
            a3[:nodes] = [] if a3[:nodes].blank?
            a3[:nodes] << a4
          end
          a2[:nodes] = [] if a2[:nodes].blank?
          a2[:nodes] << a3
        end
      end
      # done with area, append it to otcArrHash
      otcArrHash << a2
    end
    # puts ("+++ otcArrHash: #{JSON.pretty_generate(otcArrHash)}")

    # convert array of areas into json to put into bootstrap treeview
    @otcJson = otcArrHash.to_json
    respond_to do |format|
      format.html { render 'index'}
      format.json { render json: {trees: @trees, subjects: @subjects, grade_bands: @gbs}}
    end

  end

  def new
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
  end

  # def create
  #   Rails.logger.debug("Tree.create params: #{tree_params.inspect}")
  #   @tree = Tree.new(tree_params)
  #   if @tree.save
  #     flash[:success] = "tree created."
  #     # I18n.backend.reload!
  #     redirect_to trees_path
  #   else
  #     render :new
  #   end
  # end

  # def show
  #   # to do - refactor so this and show_outcome are same action and view
  #   # get all translation keys for this record and above
  #   treeKeys = @tree.getAllTransNameKeys
  #   # get all translation keys for all sectors related to it
  #   @tree.sectors.each do |s|
  #     treeKeys << s.name_key
  #   end
  #   # get the translation key for the related sectors explanation
  #   treeKeys << "#{@tree.base_key}.explain"
  #   @translations = Translation.translationsByKeys(@locale_code, treeKeys)
  #   all_codes = JSON.load(@tree.matching_codes)
  #   trans = @translations[@tree.buildNameKey]
  #   all_translations = JSON.load(trans)
  #   @group_indicators = []
  #   all_codes.each_with_index do |c, ix|
  #     thisCode = @tree.codeByLocale(@locale_code, ix)
  #     @group_indicators << [thisCode, all_translations[ix]] if all_translations.length > ix
  #   end
  # end

  def sequence
    index_prep

    @s_o_hash = Hash.new  { |h, k| h[k] = [] }
    @indicator_hash = Hash.new { |h, k| h[k] = [] }
    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @trees = listing.joins(:grade_band).order("trees.sequence_order, code").all
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )

    treeHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}
    @subj_gradebands = Hash.new { |h, k| h[k] =  [] }
    @gradebands = ["All", *listing.joins(:grade_band).pluck('grade_bands.code').uniq]
    @subjects = {}
    subjIds = {}
    subjects = Subject.all
    subjects.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
      @s_o_hash[s.code] = []
      @subj_gradebands[s.code] = listing.joins(:subject).where('subjects.code' => s.code).joins(:grade_band).pluck('grade_bands.code').uniq
    end


    @relations = Hash.new { |h, k| h[k] = [] }
    relations = TreeTree.active
    relations.each do |rel|
      @relations[rel.tree_referencer_id] << rel
    end

    # Translations table no longer belonging to I18n Active record gem.
    # note: Active Record had problems with placeholder conditions in join clause.
    # Consider having Translations belong_to trees and sectors.
    # Current solution: get translation from hash of pre-cached translations.
    base_keys= @trees.map { |t| "#{t.base_key}.name" }
    base_keys =  base_keys | subjects.map { |s| "#{s.base_key}.name" }
    base_keys = base_keys | subjects.map { |s| "#{s.base_key}.abbr" }
    base_keys = base_keys | relations.map { |r| r.explanation_key }

    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: base_keys)
    translations.each do |t|
      # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
      @translations[t.key] = t.value
    end

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.name_key]
      areaHash = {}
      depth = tree.depth
      case depth

      # when 1
      #   newHash = {text: "#{I18n.translate('app.labels.grade_band')} #{tree.subCode}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   # add grade (band) if not there already
      #   treeHash[tree.codeArrayAt(0)] = newHash if !treeHash[tree.codeArrayAt(0)].present?

      # when 2
      #   newHash = {text: "#{I18n.translate('app.labels.area')} #{tree.codeArrayAt(1)}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   puts ("+++ codeArray: #{tree.codeArray.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   end
      #   Rails.logger.debug("*** #{tree.codeArrayAt(1)} to area #{tree.codeArrayAt(0)} in treeHash")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)], tree.subCode, newHash)

      # when 3
      #   newHash = {text: "#{I18n.translate('app.labels.component')} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", nodes: {}}
      #   puts ("+++ codeArray: #{tree.codeArray.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
      #     raise I18n.t('trees.errors.missing_area_in_tree')
      #   end
      #   Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)], tree.subCode, newHash)

      when 4
        tcode = tree.subject.code + tree.code.split('.').join('')
        newHash = {
          code: tcode,
          text: "#{tree.code}: #{translation}",
          id: "#{tree.id}",
          gb_code: tree.grade_band.code,
          connections: @relations[tree.id]
        }
        # if treeHash[tree.codeArrayAt(0)].blank?
        #   raise I18n.t('trees.errors.missing_grade_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
        #   raise I18n.t('trees.errors.missing_area_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
        #   raise I18n.t('trees.errors.missing_component_in_tree')
        #end
        @s_o_hash[tree.subject.code] << newHash
        #addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)], tree.subCode, newHash)

      when 5
      #   # # to do - look into refactoring this
      #   # # check to make sure parent in hash exists.
      #   # Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
      #   # Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
      #   # Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
        newHash = {label: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}:", text: "#{translation}", id: "#{tree.id}"}
        parent_code = tree.code.split('.')
        parent_code.pop()
        parent_code = parent_code.join('')
        @indicator_hash["#{tree.subject.code}#{parent_code}"] << newHash
      #   # Rails.logger.debug("indicator newhash: #{newHash.inspect}")
      #   if treeHash[tree.codeArrayAt(0)].blank?
      #     raise I18n.t('trees.errors.missing_grade_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
      #     raise I18n.t('trees.errors.missing_area_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
      #     raise I18n.t('trees.errors.missing_component_in_tree')
      #   elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
      #     Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
      #     raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
      #   end
      #   Rails.logger.debug("*** translation: #{translation.inspect}")
      #   addNodeToArrHash(treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)], tree.codeArrayAt(4), newHash)

      else
        # raise I18n.t('translations.errors.tree_too_deep_id', id: tree.id)
      end
    end

    respond_to do |format|
      format.html { render 'sequence'}
    end
  end

  def dimensions
    puts "params #{params}"
    # index_prep

    # array of all translation keys, to be used to load up @translations instance variable with the tranlation values
    transl_keys = []

    listing = Tree.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @trees = listing.joins(:grade_band).order("trees.sequence_order, code").all

    transl_keys = @trees.map { |t| "#{t.base_key}.name" }

    @relations = Hash.new { |h, k| h[k] = [] }
    relations = DimTree.active
    relations.each do |rel|
      if (rel.dimension[:dim_type] == params[:dim_type])
        @relations["tree_id_#{rel.tree_id}"] << rel
        @relations["dim_id_#{rel.dimension_id}"] << rel
        transl_keys << rel[:dim_explanation_key]
      end
    end

    @s_o_hash = Hash.new  { |h, k| h[k] = Hash.new }
    @indicator_hash = Hash.new { |h, k| h[k] = [] }
    @subj_gradebands = Hash.new { |h, k| h[k] = [] }
    @subjects = {}
    subjIds = {}
    subjects = Subject.all
    subjects.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
      @s_o_hash[s.code] = {
        :dimensions => [],
        :los => []
      }
      @subj_gradebands[s.code] = listing.joins(:subject).where('subjects.code' => s.code).joins(:grade_band).pluck('grade_bands.code').uniq
      @subj_gradebands[s.code] << "All" if @subj_gradebands[s.code].length > 1
      transl_keys << s.base_key+'.name'
      transl_keys << s.base_key+'.abbr'
    end

    Rails.logger.debug("*** @subjects: #{@subjects.inspect}")
    Rails.logger.debug("*** subjIds: #{subjIds.inspect}")

    @dim_type = (Dimension::VAL_DIM_TYPES.include?(params['dim_type'])) ? params['dim_type'] : ''

    if @dim_type.present?
      dimRecs = Dimension.where(
        dim_type: @dim_type
      )
      Rails.logger.debug("*** dimRecs: #{dimRecs.inspect}")

      @page_title = I18n.translate(Dimension::DIM_TYPE_KEYS[@dim_type])

      dimRecs.each do |r|
        subj_code = subjIds[r.subject_id.to_s].code
        dimHash = {
          id: r.id,
          subject_id: r.subject_id,
          code: r.dim_code,
          dim_name_key: r.dim_name_key,
          dim_desc_key: r.dim_desc_key,
          rel: @relations["dim_id_#{r.id}"]
        }
        transl_keys << r.dim_name_key
        transl_keys << r.dim_desc_key
        Rails.logger.debug("*** newHash: #{dimHash.inspect}")
        @s_o_hash[subj_code][:dimensions] << dimHash
        @s_o_hash['sci'][:dimensions] << dimHash
      end
      Rails.logger.debug("*** @s_o_hash: #{@s_o_hash.inspect}")

      @translations = Hash.new
      translations = Translation.where(locale: @locale_code, key: transl_keys)
      translations.each do |t|
        # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
        @translations[t.key] = t.value
      end
      Rails.logger.debug("*** @translations: #{@translations.inspect}")

       # create ruby hash from tree records, to easily build tree from record codes
      @trees.each do |tree|
        translation = @translations[tree.name_key]
        depth = tree.depth
        case depth
        when 4
          tcode = tree.subject.code + tree.code.split('.').join('')
          newHash = {
            code: tcode,
            text: "#{tree.code}: #{translation}",
            id: "#{tree.id}",
            gb_code: tree.grade_band.code,
            rel: @relations["tree_id_#{tree.id}"]
          }
          @s_o_hash[tree.subject.code][:los] << newHash
        end
      end

      respond_to do |format|
        format.html { render 'dimensions'}
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end


  def edit_dimensions
    errors = []
    @explanation = ''
    @tree = Tree.find(tree_params[:tree_id])
    @dim = Dimension.find(tree_params[:dimension_id])
    #Check whether a tree_tree for this relationship already exists.
    dim_tree_matches = DimTree.where(
      :tree_id => tree_params[:tree_id],
      :dimension_id => tree_params[:dimension_id])
    subj_translation_matches = Translation.where(
        :key => @tree.subject[:base_key] + '.name',
        :locale => @locale_code
        )
    dimension_translation_matches = Translation.where(
        :key => @dim[:dim_name_key],
        :locale => @locale_code
        )

    #Might not exist for every locale! Will fail if subject doesn't have
    #a translation.
    @tree_subject_translation = subj_translation_matches.first.value
    #Might not exist for every locale!
    @dimension_translation = dimension_translation_matches.first.value
    if dim_tree_matches.length == 0
      @dim_tree = DimTree.new(tree_params)
      @dim_tree.dim_explanation_key = "TFV.v01.#{@tree.subject.code}.#{@tree.code}.bigidea.#{@dim.id}.expl"
      @method = :post
      @form_path = :create_dim_tree_trees
    else
      @dim_tree = dim_tree_matches.first
      @method = :patch
      @form_path = :update_dim_tree_trees
      explanation_translation_matches = Translation.where(
          :key => @dim_tree[:dim_explanation_key],
          :locale => @locale_code
        )
      @explanation = explanation_translation_matches.first.value if (explanation_translation_matches.length > 0)
    end #no errors
    puts "try to respond with modal popup"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_dim_tree
    errors = []
    puts "create!!! #{params}"
    @dim_tree = DimTree.new(
      :dimension_id => dim_tree_params[:dimension_id],
      :tree_id => dim_tree_params[:tree_id],
      :dim_explanation_key => dim_tree_params[:dim_explanation_key]
    )
    @translation = Translation.new(
      :key => dim_tree_params[:dim_explanation_key],
      :value => dim_tree_params[:explanation],
      :locale => @locale_code
    )
    ActiveRecord::Base.transaction do
      begin
        @dim_tree.save!
        @translation.save!
      rescue ActiveRecord::StatementInvalid => e
        errors << e
      end
    end #end transaction
    redirect_to controller: 'trees', action: 'dimensions', dim_type: dim_tree_params[:dim_type]
  end

  def update_dim_tree
    puts "update!!!"
    @dim_tree = DimTree.find dim_tree_params[:id]
    translation_matches = Translation.where(
      :locale => @locale_code,
      :key => dim_tree_params[:dim_explanation_key]
    )
    if translation_matches.length == 0
      @translation = Translation.new(
        :key => dim_tree_params[:dim_explanation_key],
        :value => dim_tree_params[:explanation],
        :locale => @locale_code
      )
    else
      @translation = translation_matches.first
      @translation.value = dim_tree_params[:explanation]
    end
    ActiveRecord::Base.transaction do
      begin
        @dim_tree.save!
        @translation.save!
      rescue ActiveRecord::StatementInvalid => e
        errors << e
      end
    end #end transaction
    redirect_to controller: 'trees', action: 'dimensions', dim_type: dim_tree_params[:dim_type]
  end

  def show
    process_tree = false
    Rails.logger.debug("*** depth: #{@tree.depth}")
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when 4
      # get the Tree Item for this Learning Outcome
      # only detail page currently is at LO level
      # Indicators are listed in the LO Detail page
      # @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
      @trees = [@tree]
      process_tree = true
    else
      # not a detail page, go back to index page
      index_prep
      render :index

    end

    if process_tree
      editMe = params['editme']
      @editMe = false
      # turn off detail editing page for now
      if editMe && editMe == @tree.id.to_s && current_user.present?
        @editMe = true
      end
      # Rails.logger.debug("*** @editMe: #{@editMe.inspect}")
      # prepare to output detail page
      @tree_items_to_display = []
      @subjects = Subject.all.order(:code)
      subjById = @subjects.map{ |rec| [rec.id, rec.code]}
      @subjById = Hash[subjById]
      Rails.logger.debug("*** @subjById: #{@subjById.inspect}")
      relatedBySubj = @subjects.map{ |rec| [rec.code, []]}
      @relatedBySubj = Hash[relatedBySubj]
      Rails.logger.debug("*** @relatedBySubj: #{@relatedBySubj.inspect}")
      # get all translation keys for this learning outcome
      treeKeys = @tree.getAllTransNameKeys
      if @tree.depth == 4
        # when outcome level, get children (indicators), to in outcome page
        @tree.getAllChildren.each do |c|
          treeKeys << c.name_key
        end

      end
      Rails.logger.debug("*** treeKeys: #{treeKeys.inspect}")
      @trees.each do |t|
        # get translation key for this item
        treeKeys << t.name_key
        # get translation key for each sector, big idea and misconception for this item
        if treeKeys
          t.sector_trees.each do |st|
            treeKeys << st.sector.name_key
            treeKeys << st.explanation_key
          end
          t.dim_trees.each do |dt|
            treeKeys << dt.dimension.dim_name_key
            treeKeys << dt.dim_explanation_key
          end
        end
        # get translation key for each related item for this item
        t.tree_referencers.each do |r|
          rTree = r.tree_referencee
          treeKeys << rTree.name_key
          treeKeys << r.explanation_key
          subCode = @subjById[rTree.subject_id]
          @relatedBySubj[subCode] << {
            code: rTree.code,
            relationship: ((r.relationship == 'depends') ? r.relationship+' on' : r.relationship+' to'),
            tkey: rTree.name_key,
            explanation: r.explanation_key,
            tid: (rTree.depth < 2) ? 0 : rTree.id,
            ttid: r.id
          } if (!@relatedBySubj[subCode].include?(rTree.code) && r.active)
        end
        treeKeys << "#{t.base_key}.explain"
        @tree_items_to_display << t
      end
      @translations = Translation.translationsByKeys(@locale_code, treeKeys)
    end
  end

  def edit
    process_tree = false
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when 4
      # get the Tree Item for this Learning Outcome
      # only detail page currently is at LO level
      # Indicators are listed in the LO Detail page
      # @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
      @trees = [@tree]
      process_tree = true if tree_params[:edit_type]
    else
      # not a detail page, go back to index page
      raise "Not an LO"

    end

    if process_tree
      @edit_type = tree_params[:edit_type]
      if @edit_type == "outcome"
        name_key = @tree.buildNameKey
        translation = Translation.translationsByKeys(
          @locale_code,
          name_key
        )
        @translation = translation[name_key]
      elsif @edit_type == "indicator"
        @indicator = Tree.find(tree_params[:attr_id])
        @attr_id = @indicator.id
        name_key = @indicator.buildNameKey
        translation = Translation.translationsByKeys(
          @locale_code,
          name_key
        )
        @translation = translation[name_key]
      elsif @edit_type == "treetree"
        @rel = TreeTree.find(tree_params[:attr_id])
        @attr_id = @rel.id
        expl_key = @rel.explanation_key
        @tree_referencee = @rel.tree_referencee
        @tree_referencee_code = I18n.t("trees.labels.#{@tree_referencee.subject.code}") + " #{@tree_referencee.code}"
        translation = Translation.translationsByKeys(
          @locale_code,
          expl_key
        )
        @explanation = translation[expl_key]
      elsif @edit_type == "sectortree"
        @rel = SectorTree.find(tree_params[:attr_id])
        @attr_id = @rel.id
        expl_key = @rel.explanation_key
        name_matches = Translation.where(
          :locale => @locale_code,
          :key => @rel.sector.name_key
          )
        @sector_name = (name_matches.length > 0 ? ": #{name_matches.first.value}" : '')
        @tree_referencee_code = "#{I18n.t('app.labels.sector_num', num: @rel.sector.code)}#{@sector_name}"
        translation = Translation.translationsByKeys(
          @locale_code,
          expl_key
        )
        @explanation = translation[expl_key]
      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    puts "+++++UPDATE PARAMS: #{params.inspect}"
    puts "+++++NIL PARAM??: #{tree_params[:attr_id]}"
    errors = []
    # if @tree.update(tree_params)
    #   flash[:notice] = "Tree  updated."
    #   # I18n.backend.reload!
    #   redirect_to trees_path
    # else
    #   render :edit
    # end
    update = tree_params[:edit_type]
    if update
      save_translation = true
      if update == 'outcome'
        name_key = @tree.buildNameKey
      elsif update == 'indicator'
        @indicator = Tree.find(tree_params[:attr_id])
        name_key = @indicator.buildNameKey
      elsif update == 'treetree'
        @tree_tree = TreeTree.find(tree_params[:attr_id])
        @reciprocal_tree_tree = TreeTree.where(
            :tree_referencee_id => @tree_tree.tree_referencer_id,
            :tree_referencer_id => @tree_tree.tree_referencee_id
          ).first
        name_key = @tree_tree.explanation_key
        @tree_tree.relationship = tree_tree_params[:relationship] if tree_tree_params[:relationship]
        @tree_tree.active = tree_tree_params[:active]
        @reciprocal_tree_tree.active = tree_tree_params[:active]
        save_translation = false if (tree_tree_params[:active].to_s == 'false')
      elsif update == 'sectortree'
        @rel = SectorTree.find(tree_params[:attr_id])
        name_key = @rel.explanation_key
        @rel.active = sector_tree_params[:active]
        save_translation = false if (sector_tree_params[:active].to_s == 'false')
      end #if update type is 'outcome', 'indicator', etc

      translation_matches = Translation.where(
        :locale => @locale_code,
        :key => name_key
      )
      if translation_matches.length > 0
        @translation = translation_matches.first
        @translation.value = tree_params[:name_translation]
      else
        @translation = Translation.new(
          :locale => @locale_code,
          :key => name_key,
          :value => tree_params[:name_translation]
        )
      end #record translation in new or existing record
        ActiveRecord::Base.transaction do
         begin
           @translation.save! if save_translation
           @tree_tree.save! if @tree_tree
           @reciprocal_tree_tree.save! if @reciprocal_tree_tree
           @rel.save! if (@rel && !save_translation)
         rescue ActiveRecord::StatementInvalid => e
           errors << e
         end
      end
    else
      errors << "Did not attempt update"
    end #if there is an update type
    flash[:alert] = "Errors prevented the LO from being updated: #{errors}" if (errors.length > 0)
    redirect_to tree_path(@tree.id)
  end

  def reorder
    Rails.logger.debug(params[:id_order].inspect)
    count = 1
    ActiveRecord::Base.transaction do
    params[:id_order].each do |id|
      t = Tree.find(id)
      t.sequence_order = count
      t.save
      count += 1
    end
    end
    respond_to do |format|
      format.json {render json: {hello_message: 'hello world'}}
    end
  end

  private

  def find_tree
    @tree = Tree.find(params[:id])
  end

  def tree_params
    params.require(:tree).permit(:id,
      :tree_type_id,
      :version_id,
      :subject_id,
      :grade_band_id,
      :code,
      :tree_id,
      :dimension_id,
      :edit_type,
      :attr_id,
      :name_translation
    )
  end

  def dim_tree_params
    params.require(:dim_tree).permit(
      :id,
      :dim_explanation_key,
      :explanation,
      :tree_id,
      :dimension_id,
      :dim_type
    )
  end

  def tree_tree_params
    params.require(:tree_tree).permit(
      :id,
      :explanation_key,
      :tree_referencer_id,
      :tree_referencee_id,
      :relationship,
      :active
    )
  end

  def sector_tree_params
    params.require(:sector_tree).permit(
      :active
    )
  end

  def reorder_params
    params.permit(:id_order)
  end

  def addNodeToArrHash (parent, subCode, newHash)
    if !parent[:nodes].present?
      parent[:nodes] = {}
    end
    # # add hash if not there already
    # if !parent[:nodes][subCode].present?
    #   parent[:nodes][subCode] = newHash
    # end
    # always add (or replace hash)
    parent[:nodes][subCode] = newHash
  end

  def index_prep
    @subjects = Subject.all.order(:code)
    @gbs = GradeBand.all
    # @gbs_upper = GradeBand.where(code: ['9','13'])
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @otcTree = ''
  end

end
