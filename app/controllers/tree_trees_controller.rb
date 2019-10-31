class TreeTreesController < ApplicationController
  # Controller for the LO connections

  def new
    @tree_tree = TreeTree.new(tree_tree_params)
    @referencer = Tree.find(tree_tree_params[:tree_referencer_id])
    Rails.logger.debug('tree_referencer:'+ @referencer.code)
    @referencee = Tree.find(tree_tree_params[:tree_referencee_id])
    Rails.logger.debug('tree_referencee:'+ @referencee.code)
    @explanation = ''
    respond_to do |format|
      format.json {render json: { 
        :tree_tree => @tree_tree,
        :referencer_code => @referencer.subject.code + "." + @referencer.code,
        :referencee_code => @referencee.subject.code + "." + @referencee.code,
        :translations => {
          :explanation => translate('tree_trees.labels.explanation'),
          :relationship => I18n.translate('trees.labels.relation'),
          :akin => I18n.translate('trees.labels.relation_types.akin'),
          :applies => I18n.translate('trees.labels.relation_types.applies'),
          :depends => I18n.translate('trees.labels.relation_types.depends')
        },
        :relation_values => {
          :applies => TreeTree::APPLIES_KEY,
          :akin => TreeTree::AKIN_KEY,
          :depends => TreeTree::DEPENDS_KEY
        }
      } 
    }
    end
  end
 

  def create
    @referencer = Tree.find(tree_tree_params[:tree_referencer_id])
    Rails.logger.debug('tree_referencer:'+ @referencer.code)
    @referencee = Tree.find(tree_tree_params[:tree_referencee_id])
    Rails.logger.debug('tree_referencee:'+ @referencee.code)
    @explanation = tree_tree_params[:explanation]
    explanation_key = @treeTypeRec.code + "." + @versionRec.code + "." 
    + @referencer.subject.code + "." + @referencer.code + ".tree." 
    + @referencee.id
    @tree_tree = TreeTree.new(
      :tree_referencer_id => tree_tree_params[:tree_referencer_id], 
      :tree_referencee_id => tree_tree_params[:tree_referencee_id],
      :relationship => tree_tree_params[:relationship],
      :explanation_key => explanation_key
      )
     
     reciprocal_explanation_key = @treeTypeRec.code + "." + @versionRec.code + "." 
    + @referencee.subject.code + "." + @referencee.code + ".tree." 
    + @referencer.id
    @tree_tree_reciprocal = TreeTree.new(
      :tree_referencer_id => tree_tree_params[:tree_referencee_id], 
      :tree_referencee_id => tree_tree_params[:tree_referencer_id],
      :relationship => TreeTree.reciprocal_relationship(tree_tree_params[:relationship]),
      :explanation_key => reciprocal_explanation_key
      )

    errors = []
    ActiveRecord::Base.transaction do
      @tree_tree.save
      @tree_tree_reciprocal.save
    end

    if errors.length > 0
      flash[:alert] = 'Error'
      redirect_to sequence_trees_path
    else
      redirect_to sequence_trees_path
    end
  end


  private

  def tree_tree_params
    params.require(:tree_tree).permit(:id,
      :tree_referencer_id,
      :tree_referencee_id,
      :relationship,
      :explanation
    )
  end

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