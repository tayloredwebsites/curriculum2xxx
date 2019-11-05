class TreeTreesController < ApplicationController
  # Controller for the LO connections
  before_action :authenticate_user!
  before_action :find_tree_tree, only: [:edit]

  def new
    errors = []

    #Check whether a tree_tree for this relationship already exists.
    tree_tree_matches = TreeTree.where(
      :tree_referencer_id => tree_tree_params[:tree_referencer_id], 
      :tree_referencee_id => tree_tree_params[:tree_referencee_id])

    if errors.length == 0 && tree_tree_matches.length == 0
      @tree_tree = TreeTree.new(tree_tree_params)
      @referencer = Tree.find(tree_tree_params[:tree_referencer_id])
      Rails.logger.debug('tree_referencer:'+ @referencer.code)
      @referencee = Tree.find(tree_tree_params[:tree_referencee_id])
      Rails.logger.debug('tree_referencee:'+ @referencee.code)
      @explanation = ''
      puts "referencer subject key: #{@referencer.subject[:base_key] + '.abbr'}, locale: #{@locale_code}"
      referencer_subject_translation = Translation.where(
        :key => @referencer.subject[:base_key] + '.name',
        :locale => @locale_code
        ).first.value
      referencee_subject_translation = Translation.where(
        :key => @referencee.subject[:base_key] + '.name',
        :locale => @locale_code
        ).first.value
    end
    if errors.length == 0 && tree_tree_matches.length == 0
      respond_to do |format|
        format.json {render json: { 
          :tree_tree => @tree_tree,
          :referencer_code => referencer_subject_translation + " " + @referencer.code,
          :referencee_code => referencee_subject_translation + " " + @referencee.code,
          :translations => {
            :modal_title => translate('trees.labels.outcome_connections'),
            :explanation_label => translate('tree_trees.labels.explanation'),
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
        }}
      end
    #If a tree_tree for this relationship already exists,
    #redirect to the edit path for that record. 
    elsif tree_tree_matches.length > 0
      redirect_to edit_tree_tree_path(tree_tree_matches.first)
    else
      respond_to do |format|
        format.json {render json: { errors: errors}}
      end
    end
  end

  def edit 
    @referencer = @tree_tree.tree_referencer
    @referencee = @tree_tree.tree_referencee
    referencer_subject_translation = Translation.where(
      :key => @referencer.subject[:base_key] + '.name',
      :locale => @locale_code
      ).first.value
    referencee_subject_translation = Translation.where(
      :key => @referencee.subject[:base_key] + '.name',
      :locale => @locale_code
      ).first.value
    explanation_translation = Translation.where(
        :key => @tree_tree[:explanation_key],
        :locale => @locale_code
      ).first.value
    respond_to do |format|
        format.json {render json: { 
        :tree_tree => @tree_tree,
        :referencer_code => referencer_subject_translation + " " + @referencer.code,
        :referencee_code => referencee_subject_translation + " " + @referencee.code,
        :translations => {
          :modal_title => translate('trees.labels.outcome_connections'),            
          :explanation_label => translate('tree_trees.labels.explanation'),
          :explanation => explanation_translation,
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
      }}
    end
  end
 

  def create
    errors = []
    if TreeTree.where(
      :tree_referencer_id => tree_tree_params[:tree_referencer_id], 
      :tree_referencee_id => tree_tree_params[:tree_referencee_id]).length > 0
      errors << "Relationship already exits."
    end
    if errors.length == 0 && TreeTree.where(
      :tree_referencee_id => tree_tree_params[:tree_referencer_id], 
      :tree_referencer_id => tree_tree_params[:tree_referencee_id]).length > 0
      errors << "Relationship already exits."
    end
    if errors.length == 0
      @referencer = Tree.find(tree_tree_params[:tree_referencer_id])
      Rails.logger.debug('tree_referencer:'+ @referencer.code)
      @referencee = Tree.find(tree_tree_params[:tree_referencee_id])
      Rails.logger.debug('tree_referencee:'+ @referencee.code)
      @explanation = tree_tree_params[:explanation]
      explanation_key = @treeTypeRec.code + "." + @versionRec.code + "." + @referencer.subject.code + "." + @referencer.code + ".tree." + @referencee.id.to_s
      @tree_tree = TreeTree.new(
        :tree_referencer_id => tree_tree_params[:tree_referencer_id], 
        :tree_referencee_id => tree_tree_params[:tree_referencee_id],
        :relationship => tree_tree_params[:relationship],
        :explanation_key => explanation_key
        )
       
       #reciprocal_explanation_key = @treeTypeRec.code + "." + @versionRec.code + "." + @referencee.subject.code + "." + @referencee.code + ".tree." + @referencer.id.to_s
      @reciprocal_tree_tree = TreeTree.new(
        :tree_referencer_id => tree_tree_params[:tree_referencee_id], 
        :tree_referencee_id => tree_tree_params[:tree_referencer_id],
        :relationship => TreeTree.reciprocal_relationship(:"#{tree_tree_params[:relationship]}"),
        :explanation_key => explanation_key
        )

      @explanation_translation = Translation.where(:locale => @locale_code, 
        :key => explanation_key)
      # @reciprocal_explanation_translation = Translation.where(:locale => @locale_code, 
      #   :key => reciprocal_explanation_key)

      if @explanation_translation.empty?
        @explanation_translation = Translation.new(
            :key => explanation_key,
            :locale => @locale_code,
            :value => tree_tree_params[:explanation]
          )
      else
        @explanation_translation = @explanation_translation.first
        @explanation_translation.value = tree_tree_params[:explanation]
      end

      ActiveRecord::Base.transaction do
         begin
           @tree_tree.save!
           @reciprocal_tree_tree.save!
           @explanation_translation.save!
         rescue ActiveRecord::StatementInvalid
           errors << e
         end
      end
    end
    if errors.length > 0
      flash[:alert] = "Errors prevented the connection from being saved: #{errors.to_s}"
      redirect_to sequence_trees_path
    else
      flash[:notice] = "Created relationship: \
      #{@referencer.subject.code}.#{@referencer.code} \
      #{translate('trees.labels.relation_types.' + tree_tree_params[:relationship]) } \
      #{@referencee.subject.code}.#{@referencee.code}."
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

  def find_tree_tree
    @tree_tree = TreeTree.find(params[:id])
  end



end