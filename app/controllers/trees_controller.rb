class TreesController < ApplicationController

  before_action :find_tree, only: [:show, :show_outcome, :edit, :update]
  before_action :authenticate_user!, only: [:reorder]
  after_action -> {flash.discard}, only: [:maint]

  def index
    index_listing
  end

  def index_listing
    treePrep

    treeHash = {}
    areaHash = {}
    componentHash = {}
    newHash = {}
    hierarchiesInTrees = []
    Rails.logger.debug("TREES: #{@trees.pluck('code')}")
    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.buildNameKey]
      areaHash = {}
      depth = tree.depth
      code_arr = tree.code.split(".")
      hierarchy_level = @hierarchies[depth - 1]
      hierarchiesInTrees << hierarchy_level if !hierarchiesInTrees.include?(hierarchy_level)

      parent = treeHash[code_arr.shift] if code_arr.length > 1
      while code_arr.length > 1
        c = code_arr.shift
        parent = parent[:nodes][c] if c != "" && parent[:nodes][c]
      end

      case depth

      when 1
        newHash = {text: "#{@hierarchies[0] if @hierarchies.length > 0} #{tree.subCode}: #{translation}", id: "#{tree.id}", outcome: tree.outcome, nodes: {}}
        # add grade (band) if not there already
        treeHash[tree.codeArrayAt(0)] = newHash if !treeHash[tree.codeArrayAt(0)].present?

      when 2
        newHash = {text: "#{@hierarchies[1] if @hierarchies.length > 1} #{tree.codeArrayAt(1)}: #{translation}", id: "#{tree.id}", outcome: tree.outcome, nodes: {}}
        Rails.logger.debug("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(1)} to area #{tree.codeArrayAt(0)} in treeHash")
        addNodeToArrHash(parent, tree.subCode, newHash)

      when 3
        newHash = {text: "#{@hierarchies[2] if @hierarchies.length > 2} #{tree.codeArrayAt(2)}: #{translation}", id: "#{tree.id}", outcome: tree.outcome, nodes: {}}
        Rails.logger.debug("+++ codeArray: #{tree.codeArray.inspect}")
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        end
        Rails.logger.debug("*** #{tree.codeArrayAt(2)} to area #{tree.codeArrayAt(1)} in treeHash")
        addNodeToArrHash(parent, tree.subCode, newHash)

      when 4
        newHash = {text: "#{@hierarchies[3] if @hierarchies.length > 3} #{tree.subCode}: #{translation}", id: "#{tree.id}", outcome: tree.outcome, nodes: {}}
        if treeHash[tree.codeArrayAt(0)].blank?
          raise I18n.t('trees.errors.missing_grade_in_tree')
        elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
          raise I18n.t('trees.errors.missing_area_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
        #   raise I18n.t('trees.errors.missing_component_in_tree')
        end
        addNodeToArrHash(parent, tree.subCode, newHash)

      when 5
        # # to do - look into refactoring this
        # # check to make sure parent in hash exists.
        # Rails.logger.debug("*** tree index_listing: #{tree.inspect}")
        # Rails.logger.debug("*** tree.name_key: #{tree.name_key}")
        # Rails.logger.debug("*** Translation for tree.name_key: #{Translation.where(locale: 'en', key: tree.name_key).first.inspect}")
        newHash = {text: "#{I18n.translate('app.labels.indicator')} #{tree.subCode}: #{translation}", id: "#{tree.id}", outcome: tree.outcome, nodes: {}}
        #If certain levels in the hierarchy are optional, these missing components are not necessarily errors.
        #
        # Rails.logger.debug("indicator newhash: #{newHash.inspect}")
        # if treeHash[tree.codeArrayAt(0)].blank?
        #   raise I18n.t('trees.errors.missing_grade_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)].blank?
        #   raise I18n.t('trees.errors.missing_area_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)].blank?
        #   raise I18n.t('trees.errors.missing_component_in_tree')
        # elsif treeHash[tree.codeArrayAt(0)][:nodes][tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)].blank?
        #   Rails.logger.error I18n.t('trees.errors.missing_outcome_in_tree')
        #   raise I18n.t('trees.errors.missing_outcome_in_tree', treeHash[tree.codeArrayAt(1)][:nodes][tree.codeArrayAt(2)][:nodes][tree.codeArrayAt(3)])
        # end
        Rails.logger.debug("*** translation: #{translation.inspect}")
        addNodeToArrHash(parent, tree.codeArrayAt(4), newHash)

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
            path4 = outc[:outcome] ? tree_path(outc[:id]) : "javascript:void(0);"
            a4 = {text: outc[:text], href: path4, setting: 'outcome'}
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

   # @hierarchiesInTrees = []
   # @hierarchies[0 .. 3].each { |h| @hierarchiesInTrees << h if hierarchiesInTrees.include?(h) }

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

  def maint
    # to do: Issue 77. Relations (Sequencing) page is page where updates to the curriculum are done. Thus this is where adds and deletes should be.
    # 1) The Relations page needs to display the hierarchy items within the listing, to clarify if a LO sequence change has moved it within the hierarchy. The hierarchy items will not be draggable (at least initially).
    # 2) An added item should be entered through a popup, indicating its parent, then entered into the correct position in the Relations page. The Sequences should be updated at this point in time (unless we remove the sort_order field).  May want to put Add and Deactivate icons in hierarchy.  May want to add deactivate icon in LOs. May need to add LO indicator to hierarchy level.

    # 3) I recommend that the LO code be reflective of the current position in the hierarchy, not what the old LO code was. Thus we should keep the old LO code when changing versions, but allow the number to change as appropriate in the hierarchy. May want to put LO Code formula (from tree_types record, with old code displayed (from prior version, or from first value when no prior version.)

    # note also Issue 6.  Allow user to change version of Curriculum.
    # - Have versions listing page, with ability to add new version, select current version, display current version and Curriculum Type in Header.

    # New Issue? - Need ability to choose the columns to display in the relations page.
    # - Always show current Curriculum Type and version, and either no subjects or last subject chosen to edit.  Maybe this should be on an Edit page?
    # - Ability to choose other subjects in this or other curriculum.  Column should show Type, Version, subject and grades.
    # - Should only be able to edit the current subject being edited.
    # - should be able to drag hierarchy items (and LOs) to the editing column on the left.

    treePrep
    dimPrep
    #To Do: Remove Alt Flag when design is finalized
    @use_alt_partial = params[:alt]
    @editing = params[:editme] && can_edit_any_dims?(@treeTypeRec)
    @page_title = @editing ? translate('trees.maint.title') : (@dim_type ? (Translation.find_translation_name(@locale_code, Dimension.get_dim_type_key(@dim_type, @treeTypeRec.code, @versionRec.code), nil) || translate('nav_bar.'+@dim_type+'.name')) : @hierarchies[@treeTypeRec.outcome_depth].pluralize )

    @competency_details = []

    @treeTypeRec.grid_headers.split(',').each do |detail|
      if (detail[0 .. 0] == "{" && detail[detail.length - 1 .. detail.length - 1] == "}") || (detail[0 .. 0] == "[" && detail[detail.length - 1 .. detail.length - 1] == "]")
        @competency_details << detail[1 .. detail.length - 2 ]
      end
    end

    Rails.logger.debug "ESSENTIAL QUESTION TRANSLATION #{@ess_q_title}"

    @treeByParents = Hash.new{ |h, k| h[k] = {} }

    # create ruby hash from tree records, to easily build tree from record codes
    @trees.each do |tree|
      translation = @translations[tree.buildNameKey]
      # Parent keys types ( Tree Type, Version, Subject, & Grade Band)
      tkey = tree.tree_type.code + "." + tree.version.code + "." + tree.subject.code + "." + tree.grade_band.code

      # column header indicating the subject and grade, and if not current one, the curriculum and version
      tkeyTrans = ''
      if (false) # when current curriculum and version are known, check if current column is not the current one
        tkeyTrans += Translation.find_translation_name(@locale_code, 'curriculum.'+tree.tree_type.code+'.title', 'Missing Curriculum Name') + ' - ' + tree.version.code + ' - '
      end
      tkeyTrans += Translation.find_translation_name(@locale_code, tree.subject.get_versioned_name_key, 'Missing Subject Name') + ' - ' + Translation.find_translation_name(@locale_code, tree.grade_band.get_name_key, 'Missing Grade Name')
      @translations[tkey] = tkeyTrans
      selectors_by_parent = tree.parentCodes.map { |pc| "child-of-#{pc.split(".").join("-")}" if pc != "" }
      selectors_by_parent = selectors_by_parent.length > 1 ? "collapsable " + selectors_by_parent.join(" ") : "top-selector" + selectors_by_parent.join(" ")
      explanation = tree.outcome ? Translation.find_translation_name(
          @locale_code,
          tree.outcome.get_explain_key,
          nil
        ) : nil
      newHash = {
        id: tree.id,
        depth: tree.depth,
        outcome: tree.outcome,
        subj_code: tree.subject.code,
        gb_code: tree.grade_band.code,
        code: tree.code,
        formatted_code: tree.outcome ? tree.format_code(@locale_code) : tree.codeArray.last,
        selectors_by_parent: selectors_by_parent,
        depth_name: @hierarchies[tree.depth-1],
        text: "#{translation}",
        explanation: explanation,
        dimtrees: @dimtrees_by_tree_id[tree.id]
        #connections: @relations[tree.id]
      }
      @treeByParents[tkey][tree.code] = newHash

      Rails.logger.debug("*** @treeByParent [#{tkey}] [#{tree.code}] = #{newHash.inspect}")
    end

    @treeByParents.each do |tkey, codeh|
      Rails.logger.debug("*** LOOP @treeByParent tkey: #{tkey}")
      codeh.each do |code, hash|
        Rails.logger.debug("*** LOOP code: #{code} => #{hash.inspect}")
      end
    end

    begin
      saved_dim_tree = @dimtrees.find(dim_tree_params[:id]) if (dim_tree_params && dim_tree_params[:id])
    rescue
      # dim_tree_params[:id] will not be found in @dimtrees,
      # and will cause a server exception
      # if the user switched curriculum versions immediately
      # after connecting a dimension to a learning outcome.
      #
      # This query could be rewritten with DimTree.find(...)
      # to prevent the exception, but then the app would try to
      # display a success notice about an action performed
      # on a different version of the curriculum.
    end
    flash[:notice] = I18n.translate("app.notice.saved_relationship", item_type_1: @hierarchies[@treeTypeRec.outcome_depth], item_desc_1: saved_dim_tree.tree.format_code(@locale_code), item_type_2: @dimTypeTitleByCode[saved_dim_tree.dimension.dim_code].singularize, item_desc_2: "\"#{@translations[saved_dim_tree.dimension.dim_name_key]}\"") if saved_dim_tree

    respond_to do |format|
      format.html { render 'maint'}
    end

  end

  def sequence
    index_prep
    @max_subjects = 6
    @s_o_hash = Hash.new  { |h, k| h[k] = [] }
    @indicator_hash = Hash.new { |h, k| h[k] = [] }
    @indicator_name = @hierarchies.length > @treeTypeRec[:outcome_depth] + 1 ? @hierarchies[@treeTypeRec[:outcome_depth] + 1].pluralize : nil
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
    subjects = Subject.where("tree_type_id = ? AND min_grade < ?", @treeTypeRec.id, 999).order("max_grade desc", "min_grade asc", "code")
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
    base_keys= @trees.map { |t| t.buildNameKey }
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
      translation = @translations[tree.buildNameKey]
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

      when  @treeTypeRec[:outcome_depth] + 1
        tcode = tree.subject.code + tree.code.split('.').join('')
        newHash = {
          code: tcode,
          text: "#{tree.format_code(@locale_code)}: #{translation}",
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

      when  @treeTypeRec[:outcome_depth] + 2
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

  #add/edit form for a dimension
  def dimension_form
    @dimension = dimension_params[:id] ? Dimension.find(dimension_params[:id]) : Dimension.new(
          dim_type: dimension_params[:dim_type]
        )
    #TO DO:
    @form_path = @dimension.id ? update_dimension_trees_path : create_dimension_trees_path
    subjects = Subject.where(:tree_type_id => @treeTypeRec.id).pluck("code").uniq
    @dimension_subject_opts = [] #used only for new dimensions?
    subjects.each do |subj_code|
      @dimension_subject_opts << {code: subj_code, name: Translation.find_translation_name(
          @locale_code,
          Subject.get_default_name_key(subj_code),
          subj_code)
      }
    end

    @dimension_subject = Translation.find_translation_name(
      @locale_code,
      Subject.get_default_name_key(@dimension.subject_code),
      @dimension.subject_code) if @dimension.subject_code
    @dimension_text = Translation.find_translation_name(
        @locale_code,
        @dimension.dim_name_key,
        ""
      ) if @dimension.dim_name_key
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_dimension
    changes = "[CREATE]"
    subject = Subject.where(
        :tree_type_id => @treeTypeRec.id,
        :code => dimension_params[:subject_code]
      ).first
    subject_id = subject ? subject.id : nil
    dimension = Dimension.create(
        :subject_code => dimension_params[:subject_code],
        :subject_id => subject_id,
        :dim_type => dimension_params[:dim_type],
        :dim_code => dimension_params[:dim_type],
        :min_grade => dimension_params[:min_grade],
        :max_grade => dimension_params[:max_grade]
      )
    dimension.update(
      :dim_name_key => dimension.get_dim_name_key,
      :dim_desc_key => dimension.get_dim_desc_key
      )
    dim_translation = Translation.create(
        :value => dimension_params[:text],
        :key => dimension.get_dim_name_key,
        :locale => @locale_code
      )

    changes += ", #{{'dimension': dimension.as_json, 'text': dim_translation.as_json}},,,[END OF LINE]"

    open(BaseRec::DIM_CHANGE_LOG_PATH, "a") do |f|
      f.puts changes
    end

    flash[:notice] = I18n.translate("app.notice.saved_item", item: dim_translation.value, item_type: @dimTypeTitleByCode[dimension.dim_code])
    redirect_to maint_trees_path(editme: true)
  end

  def update_dimension
    changes = "[CHANGE]"
    dimension = Dimension.find(dimension_params[:id])
    if dimension_params[:min_grade]
      dimension.min_grade = dimension_params[:min_grade]
      changes += ", min_grade: #{dimension_params[:min_grade]}"
    end
    if dimension_params[:max_grade]
    dimension.max_grade = dimension_params[:max_grade]
    changes += ", max_grade: #{dimension_params[:max_grade]}"
    end
    if dimension_params[:active]
      dimension.active = dimension_params[:active]
      changes += ", active: #{dimension_params[:active]}"
    end

    dimension.save

    if dimension_params[:text]
      Translation.find_or_update_translation(@locale_code,
          dimension.get_dim_name_key,
          dimension_params[:text]
        )
      changes += ", text: #{dimension_params[:text]}"
    end
    changes += ",,,[END OF LINE]"
    translation = Translation.find_translation_name(
        @locale_code,
        dimension.get_dim_name_key,
        dimension.get_dim_name_key
      )

    open(BaseRec::DIM_CHANGE_LOG_PATH, "a") do |f|
      f.puts changes
    end

    flash[:notice] = I18n.translate("app.notice.saved_item", item: translation, item_type: @dimTypeTitleByCode[dimension.dim_code])

    redirect_to maint_trees_path(editme: true)
  end

  def dimensions
    Rails.logger.debug "params #{params}"
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
    subjects = Subject.where("tree_type_id = ? AND min_grade < ?", @treeTypeRec.id, 999).order("max_grade desc", "min_grade asc", "code")
    @default_subj_code = subjects.first.code if subjects.count > 0
    include_science = subjects.pluck('code').include?("sci")
    subjects.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
      @s_o_hash[s.code] = {
        :dimensions => [],
        :los => []
      }
      @subj_gradebands[s.code] = listing.joins(:subject).where('subjects.code' => s.code).joins(:grade_band).pluck('grade_bands.code').uniq
      @subj_gradebands[s.code] << "All" if @subj_gradebands[s.code].length > 1
      transl_keys << Subject.get_default_name_key(s.code)
      transl_keys << Subject.get_default_abbr_key(s.code)
    end

    Rails.logger.debug("*** @subjects: #{@subjects.inspect}")
    Rails.logger.debug("*** subjIds: #{subjIds.inspect}")

    @dim_type = (Dimension::VAL_DIM_TYPES.include?(params['dim_type'])) ? params['dim_type'] : ''

    if @dim_type.present?
      dimRecs = Dimension.where(
        dim_type: @dim_type
      )
      Rails.logger.debug("*** dimRecs: #{dimRecs.inspect}")

      @page_title = @dimTypeTitleByCode[@dim_type]

      dimRecs.each do |r|
        if subjIds[r.subject_id.to_s]
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
          @s_o_hash['sci'][:dimensions] << dimHash if include_science
        end
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
        translation = @translations[tree.buildNameKey]
        depth = tree.depth
        case depth
        when  @treeTypeRec[:outcome_depth] + 1
          tcode = tree.subject.code + tree.code.split('.').join('')
          newHash = {
            code: tcode,
            text: "#{tree.format_code(@locale_code)}: #{translation}",
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
    @show_ess_q = true if params[:show_ess_q]
    @show_bigidea = true if params[:show_bigidea]
    @show_miscon = true if params[:show_miscon]
    @tree = Tree.find(tree_params[:tree_id])
    @dim = Dimension.find(tree_params[:dimension_id])
    dimPrep
    #Check whether a tree_tree for this relationship already exists.
    dim_tree_matches = DimTree.where(
      :tree_id => tree_params[:tree_id],
      :dimension_id => tree_params[:dimension_id])
    dimension_translation_matches = Translation.where(
        :key => @dim.get_dim_name_key,
        :locale => @locale_code
        )

    #Might not exist for every locale! Will fail if subject doesn't have
    #a translation.
    @tree_subject_translation = @tree.subject.get_name(@locale_code)
    #Might not exist for every locale!
    @dimension_translation = dimension_translation_matches.first ? dimension_translation_matches.first.value : ""
    if dim_tree_matches.length == 0
      @dim_tree = DimTree.new(tree_params)
      @dim_tree.dim_explanation_key = DimTree.getDimExplanationKey(@tree[:base_key], @dim[:dim_code], @dim[:id])
      @method = :post
      @form_path = :create_dim_tree_trees
    else
      @dim_tree = dim_tree_matches.first
      @method = :patch
      @form_path = :update_dim_tree_trees
    end #no errors
    Rails.logger.debug "try to respond with modal popup"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_dim_tree
    errors = []
    Rails.logger.debug "create!!! #{params}"
    @dim_tree = DimTree.new(
      :dimension_id => dim_tree_params[:dimension_id],
      :tree_id => dim_tree_params[:tree_id],
      :dim_explanation_key => dim_tree_params[:dim_explanation_key]
    )
    ActiveRecord::Base.transaction do
      begin
        @dim_tree.save!
      rescue ActiveRecord::StatementInvalid => e
        errors << e
      end
    end #end transaction
    options = {editme: true}
    options[:show_ess_q] = true if params[:show_ess_q]
    options[:show_bigidea] = true if params[:show_bigidea]
    options[:show_miscon] = true if params[:show_miscon]
    options[:dim_tree] = { id: @dim_tree.id }
    options[:dim_tree][:bigidea_gb_id] = dim_tree_params[:bigidea_gb_id] if dim_tree_params[:bigidea_gb_id]
    options[:dim_tree][:miscon_gb_id] = dim_tree_params[:miscon_gb_id] if dim_tree_params[:miscon_gb_id]
    options[:dim_tree][:bigidea_subj_id] = dim_tree_params[:bigidea_subj_id]
    options[:dim_tree][:miscon_subj_id] = dim_tree_params[:miscon_subj_id]
    redirect_to maint_trees_path(options)
  end

  def update_dim_tree
    @dim_tree = DimTree.find dim_tree_params[:id]
    @dim_tree.active = dim_tree_params[:active]
    ActiveRecord::Base.transaction do
      begin
        @dim_tree.save!
      rescue ActiveRecord::StatementInvalid => e
        errors << e
      end
    end #end transaction
    options = {editme: true}
    options[:show_ess_q] = true if params[:show_ess_q]
    options[:show_bigidea] = true if params[:show_bigidea]
    options[:show_miscon] = true if params[:show_miscon]
    options[:dim_tree] = { id: @dim_tree.id }
    options[:dim_tree][:bigidea_gb_id] = dim_tree_params[:bigidea_gb_id] if dim_tree_params[:bigidea_gb_id]
    options[:dim_tree][:miscon_gb_id] = dim_tree_params[:miscon_gb_id] if dim_tree_params[:miscon_gb_id]
    options[:dim_tree][:bigidea_subj_id] = dim_tree_params[:bigidea_subj_id]
    options[:dim_tree][:miscon_subj_id] = dim_tree_params[:miscon_subj_id]
    redirect_to maint_trees_path(options)
  end

  def show
    process_tree = false
    Rails.logger.debug("*** depth: #{@tree.depth}")
    case @tree.depth
      # process this tree item, is at proper depth to show detail
    when  @treeTypeRec[:outcome_depth] + 1
      # get the Tree Item for this Learning Outcome
      # only detail page currently is at LO level
      # Indicators are listed in the LO Detail page
      # @trees = Tree.where('depth = 3 AND tree_type_id = ? AND version_id = ? AND subject_id = ? AND grade_band_id = ? AND code LIKE ?', @tree.tree_type_id, @tree.version_id, @tree.subject_id, @tree.grade_band_id, "#{@tree.code}%")
      @trees = [@tree]
      process_tree = true
      detail_areas = @treeTypeRec.detail_headers.split(",")
      @detail_headers = []
      @detail_areas = []
      hierarchy_codes = @treeTypeRec.hierarchy_codes.split(",").map { |h| h.split("_").join("") }
      detail_areas.each do |a|
        detail_type = 'header'
        detail = a
        if a.first == "{" && a.last == "}"
          detail_type = 'single'
          detail = a[1..a.length - 2]
        elsif a.first == "[" && a.last == "]"
          detail_type = 'multi'
          detail = a[1..a.length - 2]
        elsif a.first == "(" && a.last == ")"
          detail_type = 'header'
          detail = a[1..a.length - 2]
        elsif a.first == "<" && a.last == "<"
          detail_type = 'left-col'
          detail = a[1..a.length - 2]
        elsif a.first == ">" && a.last == ">"
          detail_type = 'right-col'
          detail = a[1..a.length - 2]
        elsif a.first == "<" && a.last == ">"
          detail_type = 'resource-col'
          detail = a[1..a.length - 2]
        end
        category_codes = detail.split("#")
        if category_codes.length > 1
          detail = category_codes[0]
          category_codes = category_codes[1..category_codes.length]
        else
          category_codes = nil
        end
        detail = detail.split("_").join("")
        @detail_headers << {type: detail_type, name: detail, depth: hierarchy_codes.index(detail) } if detail_type == 'header'
        @detail_areas << {type: detail_type, name: detail, codes: category_codes} if detail_type != 'header'
      end
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
      @indicator_name = @hierarchies.count > @treeTypeRec[:outcome_depth] + 1 ? @hierarchies[@treeTypeRec[:outcome_depth] + 1].pluralize : nil
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
          treeKeys << c.buildNameKey
        end

      end
      Rails.logger.debug("*** treeKeys: #{treeKeys.inspect}")
      @trees.each do |t|
        # get translation key for this item
        treeKeys << t.buildNameKey
        # get translation key for each sector, big idea and misconception for this item
        if treeKeys
          t.sector_trees.each do |st|
            treeKeys << st.sector.name_key
            #treeKeys << st.explanation_key
          end
          t.dim_trees.where(:active => true).each do |dt|
            treeKeys << dt.dimension.dim_name_key
            #treeKeys << dt.dim_explanation_key
          end
        end
        # get translation key for each related item for this item
        t.tree_referencers.each do |r|
          rTree = r.tree_referencee
          treeKeys << rTree.buildNameKey
          treeKeys << r.explanation_key
          subCode = @subjById[rTree.subject_id]
          @relatedBySubj[subCode] << {
            code: rTree.format_code(@locale_code),
            relationship: I18n.translate("trees.labels.relation_types.#{r.relationship}"),
            tkey: rTree.buildNameKey,
            subj: rTree.subject.get_name(@locale_code),
           # explanation: r.explanation_key,
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
    when @treeTypeRec[:outcome_depth] + 1
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
      elsif @edit_type == "comment"
         @comment = Translation.find_translation_name(@locale_code,@tree.outcome.get_explain_key, "")
      elsif Outcome::RESOURCE_TYPES.include?(@edit_type)
        @ref = Translation.find_translation_name(
            @locale_code,
            @tree.outcome.get_ref_key(@edit_type),
            ""
          )
        #To Do: normalize these translations
        @ref_label = I18n.t("trees.labels.teacher_field_#{Outcome::RESOURCE_TYPES.index(@edit_type) + 1}", sector_set: @sectorName)
      elsif @edit_type.split("#")[0] == "ref_settings"
        resource_types = @edit_type.split("#")
        if resource_types.length > 1
          resource_types = resource_types[1..resource_types.length].map { |n| Outcome::RESOURCE_TYPES[n.to_i] }
        end
        @ref_titles = resource_types.map { |t| Outcome.get_ref_hash(t, @locale_code, @sectorName) }
      elsif @edit_type == "treetree"
        @rel = TreeTree.find(tree_params[:attr_id])
        @attr_id = @rel.id
        expl_key = @rel.explanation_key
        @tree_referencee = @rel.tree_referencee
        @tree_referencee_code = @tree_referencee.format_code(@locale_code)
        translation = Translation.translationsByKeys(
          @locale_code,
          expl_key
        )
        @explanation = translation[expl_key]
      elsif @edit_type == "sector" || @edit_type == "dimtree"
        if tree_params[:attr_id] != "new"
          @rel = SectorTree.find(tree_params[:attr_id]) if (@edit_type == "sector")
        else
          @rel = SectorTree.new
          @sectors = Sector.where(:sector_set_code => TreeType.get_sector_set_code(@treeTypeRec.sector_set_code))
          @sector_names = Translation.translationsByKeys(@locale_code, @sectors.pluck('name_key'))
        end
        @rel = DimTree.find(tree_params[:attr_id]) if (@edit_type == "dimtree")
        @attr_id = @rel.id
        name_key = @edit_type == "sector" ? (@rel.id ? @rel.sector.name_key : nil) : @rel.dimension.dim_name_key
        name_matches = Translation.where(
          :locale => @locale_code,
          :key => name_key
          )
        @rel_name = (name_matches.length > 0 ? ": #{name_matches.first.value}" : '')
        @tree_referencee_code = "#{I18n.t('app.labels.sector_num', num: @rel.sector.code)}#{@rel_name}" if (@edit_type == "sector" && @rel.id)
        @tree_referencee_code = "#{Dimension.get_dim_type_name(@rel.dimension.dim_type, @treeTypeRec.code, @versionRec.code, @locale_code).singularize} #{@rel_name}" if @edit_type == "dimtree"
      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    Rails.logger.debug "+++++UPDATE PARAMS: #{params.inspect}"
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
      Translation.find_or_update_translation(@locale_code, @tree.outcome.get_explain_key, tree_params[:comment]) if tree_params[:comment]
      if update == 'outcome'
        name_key = @tree.buildNameKey
      elsif update == 'indicator'
        @indicator = Tree.find(tree_params[:attr_id])
        name_key = @indicator.buildNameKey
      elsif Outcome::RESOURCE_TYPES.include?(update)
        save_translation = false
        puts "RESOURCE: #{tree_params[:resource]}"
        Translation.find_or_update_translation(
            @locale_code,
            @tree.outcome.get_ref_key(update),
            tree_params[:resource].split("<script>").join("").split("</script>").join("")
          )
      elsif tree_params[:resource_name]
        tree_params[:resource_name].each_with_index do |name, i|
          Translation.find_or_update_translation(
            @locale_code,
            tree_params[:resource_key][i],
            name
            )
        end
      elsif update == 'treetree'
        @tree_tree = TreeTree.find(tree_params[:attr_id])
        @reciprocal_tree_tree = TreeTree.where(
            :tree_referencee_id => @tree_tree.tree_referencer_id,
            :tree_referencer_id => @tree_tree.tree_referencee_id
          ).first
        name_key = @tree_tree.explanation_key
        @tree_tree.relationship = tree_tree_params[:relationship] if tree_tree_params[:relationship]
        @tree_tree.active = tree_params[:active]
        @reciprocal_tree_tree.active = tree_params[:active]
        save_translation = false if (tree_tree_params[:active].to_s == 'false')
      elsif update == 'sector' || update == 'dimtree'
        if tree_params[:attr_id].length > 0
          @rel = update == 'sector' ? SectorTree.find(tree_params[:attr_id]) : DimTree.find(tree_params[:attr_id])
        else
          @rel = SectorTree.where(:explanation_key => SectorTree.explanationKey(@treeTypeRec.code, @versionRec.code, @tree.id, tree_params[:sector_id]))
          if @rel.length <= 0
            @rel = SectorTree.new
            @rel.tree_id = @tree.id
            @rel.sector_id = tree_params[:sector_id]
            @rel.explanation_key = SectorTree.explanationKey(@treeTypeRec.code, @versionRec.code, @tree.id, tree_params[:sector_id])
          else
            @rel = @rel.first
          end
        end
        name_key = update == 'sector' ? @rel.explanation_key : @rel.dim_explanation_key
        @rel.active = tree_params[:active] #if (update == 'sector')
        save_translation = false if (tree_params[:active].to_s == 'false')
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
           @rel.save! if @rel
         rescue ActiveRecord::StatementInvalid => e
           errors << e
         end
      end
    else
      errors << "Did not attempt update"
    end #if there is an update type
    flash[:alert] = "Errors prevented the LO from being updated: #{errors}" if (errors.length > 0)
    redirect_to tree_path(@tree.id, editme: @tree.id)
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
      :sector_id,
      :edit_type,
      :attr_id,
      :name_translation,
      :active,
      :editing,
      :comment,
      :resource,
      :resource_name => [],
      :resource_key => [],
    )
  end

  def dim_tree_params
    begin
      params.require(:dim_tree).permit(
        :id,
        :dim_explanation_key,
        :explanation,
        :tree_id,
        :dimension_id,
        :dim_type,
        :active,
      )
    rescue
      nil
    end
  end

  def dimension_params
    params.require(:dimension).permit(
      :id,
      :active,
      :subject_code,
      :subject_id,
      :dim_type,
      :dim_code,
      :dim_name_key,
      :dim_desc_key,
      :min_grade,
      :max_grade,
      :text,
      :desc
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
    @subjects = Subject.where("tree_type_id = ? AND min_grade < ?", @treeTypeRec.id, 999).order("max_grade desc", "min_grade asc", "code")
    @gbs = GradeBand.all
    # @gbs_upper = GradeBand.where(code: ['9','13'])
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @otcTree = ''
  end

  def treePrep
    Rails.logger.debug("*** @treeTypeRec: #{@treeTypeRec.inspect}")
    @subjects = {}
    subjIds = {}
    @subj_list = Subject.where("tree_type_id = ? AND min_grade < ?", @treeTypeRec.id, 999).order("max_grade desc", "min_grade asc", "code")
    @subj_list.each do |s|
      @subjects[s.code] = s
      subjIds[s.id.to_s] = s
    end
    Rails.logger.debug("*** @subjects: #{@subjects.inspect}")
    @gbs = GradeBand.where(tree_type_id: @treeTypeRec.id)
    # @gbs_upper = GradeBand.where(code: ['9','13'])
    Rails.logger.debug("*** @gbs: #{@gbs.inspect}")

    # get subject from tree param or from cookie (app controller getSubjectCode)
    if params[:tree].present? && tree_params[:subject_id].present? && subjIds[tree_params[:subject_id]]
      @subj = subjIds[tree_params[:subject_id]]
      Rails.logger.debug("*** index_listing params ID: #{tree_params[:subject_id]}")
    elsif @subject_code.present? && @subjects[@subject_code].present?
      @subj = @subjects[@subject_code]
      Rails.logger.debug("*** index_listing @subject_code: #{@subject_code.inspect}")
    elsif @subjects.first
      subjCode, @subj = @subjects.first
      Rails.logger.debug("*** index_listing no match: #{subjCode} #{@subj.inspect}")
    else
      @subj = @subj_list.first || Subject.new
    end

    Rails.logger.debug("*** @subject_code: #{@subject_code.inspect}")
    Rails.logger.debug("*** @subj: #{@subj.inspect}")
    Rails.logger.debug("*** @subj.abbr(@locale_code): #{@subj.abbr(@locale_code).inspect}")
    setSubjectCode(@subj.code)

    # get gradeBand from tree param or from cookie (app controller getSubjectCode)
    if (params[:tree].present? && tree_params[:grade_band_id] == '0') || (!params[:tree].present? && @grade_band_code == 0)
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = GradeBand.where(:tree_type_id => @treeTypeRec.id).first
    elsif params[:tree].present? && tree_params[:grade_band_id].present?
      @gb = GradeBand.find(tree_params[:grade_band_id])
      @grade_band_code = @gb.code
      Rails.logger.debug("*** index_listing gb params ID: #{tree_params[:grade_band_id]}, code: #{@gb.code}")
    elsif @grade_band_code.present?
      @gb = GradeBand.where(code: @grade_band_code, tree_type_id: @treeTypeRec.id).first
      Rails.logger.debug("*** index_listing @grade_band_code: #{@grade_band_code.inspect}")
      @grade_band_code = @gb.code
    elsif @gbs.first
      @gb = @gbs.first
      @grade_band_code = @gb.code
      Rails.logger.debug("*** index_listing no match: #{@gb.inspect}")
    else
      Rails.logger.debug("*** defaults: #{@grade_band_code}")
      @gb = nil
      @grade_band_code = ''
    end
    setGradeBandCode(@grade_band_code) #if @gb
    Rails.logger.debug("*** @grade_band_code: #{@grade_band_code.inspect}")
    Rails.logger.debug("*** @gb: #{@gb.inspect}")

    listing = Tree.active.where(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    Rails.logger.debug("*** listing.count: #{listing.count}")
    listing = listing.where(subject_id: @subj.id) if @subj.present?
    Rails.logger.debug("*** listing.count: #{listing.count}")
    listing = listing.where(grade_band_id: @gb.id) if @gb.present?
    Rails.logger.debug("*** listing.count: #{listing.count}")

    # @tree is used for filtering form
    @tree = Tree.new(
      tree_type_id: @treeTypeRec.id,
      version_id: @versionRec.id
    )
    @tree.subject_id = @subj.id if @subj.present?
    @tree.grade_band_id = @gb.id if @gb.present?

    # Note: sort order does matter for sequence of siblings in tree.
    @trees = listing.joins(:grade_band).order("grade_bands.sort_order, trees.sort_order, code").all
    Rails.logger.debug("*** @trees.count: #{@trees.count}")

    @relations = Hash.new { |h, k| h[k] = [] }
    relations = TreeTree.active
    relations.each do |rel|
      @relations[rel.tree_referencer_id] << rel
    end

    # Translations table no longer belonging to I18n Active record gem.
    # note: Active Record had problems with placeholder conditions in join clause.
    # Consider having Translations belong_to trees and sectors.
    # Current solution: get translation from hash of pre-cached translations.
    base_keys= @trees.map { |t| t.buildNameKey }

    hierarchiesInTrees = @trees.pluck('depth').uniq.map {|d| @hierarchies[d] if d <= @treeTypeRec[:outcome_depth] }
    @hierarchiesInTrees = []
    @hierarchies[0 .. 3].each { |h| @hierarchiesInTrees << h if hierarchiesInTrees.include?(h) }

    tempArray = []
    @subjects.each { |k, v| tempArray << "#{v.base_key}.name" }
    @subjects.each { |s, v| tempArray << "#{v.base_key}.abbr" }
    relations.each { |r| tempArray << r.explanation_key }
    base_keys.concat(tempArray)

    @translations = Hash.new
    translations = Translation.where(locale: @locale_code, key: base_keys)
    translations.each do |t|
      # puts "t.key: #{t.key.inspect}, t.value: #{t.value.inspect}"
      @translations[t.key] = t.value
    end
  end


  def dimPrep
    @dimensions = {}
    @dimtrees_by_tree_id = Hash.new{ |h, k| h[k] = [] }
    @subj_key_by_dt_id = {}
    @visible_dim_codes_arr = []
    dimKeys = []
    default_subj_code = @trees && @trees.first.present? ? @trees.first.subject.code : Subject.where(:tree_type_id => @treeTypeRec.id).order("min_grade asc").first.code
    default_gb = { min_grade: GradeBand::MIN_GRADE, max_grade: GradeBand::MAX_GRADE}
    @dim_type = dim_tree_params && dim_tree_params[:dim_type] ? dim_tree_params[:dim_type] : nil
    @dim_filters_str = cookies[:dim_filters].split(" ").join(",") if cookies[:dim_filters]

    # dim_filters = {
    #   "bigidea" : {
    #     :subj => "sci",
    #     :gb => {
    #       min_grade: 0,
    #       max_grade: 12,
    #       id: 5 #(optional)
    #     }
    #   },
    #   "miscon" : {...},
    #   ...
    # }
    @dim_filters = Dimension.parse_filters(
      (@dim_filters_str ? @dim_filters_str : ""),
      @treeTypeRec.dim_codes.split(","))

    #####################################################
    # Set Subject Code and GradeBand to Display for Dimension Columns
    # on the maint pages (i.e., editing, big ideas, etc.)

    @dimsArray.each do |dimObj|
      dim = dimObj[:code]
      if !@dim_filters[dim][:subj]
        @dim_filters[dim][:subj] = default_subj_code
      end
      if !@dim_filters[dim][:gb] && @dim_filters[dim][:subj]
        subjs = Subject.where('code = ? AND max_grade < ?', @dim_filters[dim][:subj], 999)
        @dim_filters[dim][:gb] = subjs.count > 0 ? {min_grade: subjs.order("min_grade asc").pluck("min_grade")[0], max_grade: subjs.order("max_grade desc").pluck("max_grade")[0]} : default_gb
      elsif !@dim_filters[dim][:gb]
        @dim_filters[dim][:gb] = default_gb
      end
      @dim_filters[dim][:gb][:min_arr] = [GradeBand::MIN_GRADE .. @dim_filters[dim][:gb][:max_grade]]
      @dim_filters[dim][:gb][:max_arr] = [@dim_filters[dim][:gb][:min_grade] .. GradeBand::MAX_GRADE]

      show_dim_code = @dim_type ? (@dim_type == dim) : (cookies[:"#{dim}_visible"] == "true")
      @visible_dim_codes_arr << dim if show_dim_code

      @dimensions[dim] = Dimension.active.where(
        dim_code: dim,
        subject_code: @dim_filters[dim][:subj],
        min_grade: @dim_filters[dim][:gb][:min_arr],
        max_grade: @dim_filters[dim][:gb][:max_arr])

      @dimensions[dim].pluck('dim_name_key').map { |k| dimKeys << k }

    end

    ####################################################
    #if @trees is prepared, look for connected dimtrees
    if @trees
      # Get dimensions and dimtrees for displayed curriculum
      @dimtrees = DimTree.active.joins(:dimension).where(:tree_id => @trees.pluck("id"))
      @dimtrees.each do |dt|
        @dimtrees_by_tree_id[dt[:tree_id]] << dt
        dt_dim = dt.dimension
        dt_dim_subj = nil
        # If the dimension will not be captured by the dimension
        # columns displayed on the page.
        if translate?(dt_dim, @dim_filters[dt_dim.dim_code])
            dimKeys << dt_dim.dim_name_key
        end
        @subj_key_by_dt_id[dt.id] = dt_dim_subj
      end
    end #if @trees is prepared, look for connected dimtrees

    ###################################################
    # BUILD TRANSLATIONS

    if @translations
      BaseRec::BASE_SUBJECTS.each do |s|
        subjNameKey = Subject.get_default_name_key(s)
        subjAbbrKey = Subject.get_default_abbr_key(s)
        dimKeys << subjNameKey if !dimKeys.include?(subjNameKey)
        dimKeys << subjAbbrKey if !dimKeys.include?(subjAbbrKey)
      end
      # BaseRec::BASE_PRACTICES.each do |s|
      #   subjNameKey = Subject.get_default_name_key(s)
      #   subjAbbrKey = Subject.get_default_abbr_key(s)
      #   dimKeys << subjNameKey if !dimKeys.include?(subjNameKey)
      #   dimKeys << subjAbbrKey if !dimKeys.include?(subjAbbrKey)
      # end
      @dimKeys = dimKeys
      dim_translations = Translation.translationsByKeys(
        @locale_code,
        dimKeys
        )
      dim_translations.each do |tKey, tVal|
        @translations[tKey] = tVal if !@translations[tKey]
      end
    end #if @translations
  end

  #def translate?(dim_type, is_dimtype, dim, min_arr, max_arr)
  def translate?(dim, filters)
    return (filters[:subj] != dim.subject_code || !(filters[:gb][:min_arr].include?(dim.min_grade) && filters[:gb][:max_arr].include?(dim.max_grade)))
  end

end
