class TreeTreesController < ApplicationController
  # Controller for the LO connections
  before_action :authenticate_user!
  before_action :find_tree_tree, only: [:edit, :update, :deactivate]
  before_action :set_reciprocal_tree_tree, only: [:edit, :update, :deactivate]
  before_action :set_explanation_translation, only: [:edit, :update]

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
      referencer_subject_translation = @referencer.subject.get_name(@locale_code)
      referencee_subject_translation = @referencee.subject.get_name(@locale_code)
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
    referencer_subject_translation = @referencer.subject.get_name(@locale_code)
    referencee_subject_translation = @referencee.subject.get_name(@locale_code)
    explanation = @explanation_translation.value if @explanation_translation
    respond_to do |format|
        format.json {render json: {
        :tree_tree => @tree_tree,
        :referencer_code => referencer_subject_translation + " " + @referencer.code,
        :referencee_code => referencee_subject_translation + " " + @referencee.code,
        :translations => {
          :modal_title => translate('trees.labels.outcome_connections'),
          :explanation_label => translate('tree_trees.labels.explanation'),
          :explanation => explanation || '',
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
        :relationship => TreeTree.reciprocal_relationship(tree_tree_params[:relationship]),
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
         rescue ActiveRecord::StatementInvalid => e
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

  def update
    puts "+++++++++++++STARTED UPDATE"
    puts "params: #{params}"
    errors = []
    notices = []
    if @tree_tree.active.to_s != tree_tree_params[:active]
      n = (tree_tree_params[:active] == 'true' ? "Activated" : "Deactivated")
      n += " " + @tree_tree.tree_referencer.subject.code + "." +
      @tree_tree.tree_referencer.code + " to " +
      @tree_tree.tree_referencee.subject.code + "." +
      @tree_tree.tree_referencee.code + " connection."
      notices << n
    end
    #TreeTree records should be created with an explanation_key, but since this
    #column is not currently reqired, if @tree_tree is lacking an explanation_key for
    #some reason, build it:
    # explanation_key = @treeTypeRec.code + "." + @versionRec.code
    #   + "." + @tree_tree.tree_referencer.subject.code + "."
    #   + @tree_tree.tree_referencer.code + ".tree."
    #   + @tree_tree.tree_referencee.id.to_s if !@tree_tree[:explanation_key]
    # #Otherwise use the explanation_key saved in @tree_tree.
    # #note: @tree_tree and @reciprocal_tree_tree should share an explanation_key
    # explanation_key = @tree_tree[:explanation_key] if @tree_tree[:explanation_key]

  ###################################
  # Set Values to Update in @tree_tree,
  # @reciprocal_tree_tree, and
  # @explanation_translation
  ###################################

    @tree_tree.relationship = tree_tree_params[:relationship] if tree_tree_params[:relationship]

    #active status must be set to @reciprocal_tree_tree as well,
    #once it's existence is ensured
    @tree_tree.active = true if (tree_tree_params[:active] != nil)
    puts "+++++++++Should update active" if (tree_tree_params[:active] != nil)
    #find and edit reciprocal TreeTree, if found,
    #or create and edit if not found.
    #Expect reciprocal TreeTree to exist, and flash a notificaiton if
    #it does not.
    if @reciprocal_tree_tree
      @reciprocal_tree_tree.relationship = TreeTree.reciprocal_relationship(:"#{tree_tree_params[:relationship]}") if tree_tree_params[:relationship]
    else
      @reciprocal_tree_tree = TreeTree.new(
        :tree_referencer_id => @tree_tree[:tree_referencee_id],
        :tree_referencee_id => @tree_tree[:tree_referencer_id],
        :relationship => TreeTree.reciprocal_relationship(:"#{tree_tree_params[:relationship]}"),
        # :explanation_key => explanation_key
      )
      notices >> "Reciprocal connection did not exist. Created one during update."
    end

    #active status (true or false) is set for @tree_tree earlier on in the update process
    @reciprocal_tree_tree.active = true if (tree_tree_params[:active] != nil)

    #Find and set explanation translations in the controller,
    #or create and set a new explanation translation if one is
    #not found.
    #Expect explanation translations not to exist for some
    #existing TreeTree connections:
    #e.g., if the locale for this update does not match
    #the locale in which the TreeTree was originally created.
    # if @explanation_translation
    #   @explanation_translation.value = tree_tree_params[:explanation] if tree_tree_params[:explanation]
    # else
    #   @explanation_translation = Translation.new(
    #       :key => explanation_key,
    #       :locale => @locale_code,
    #       :value => tree_tree_params[:explanation])
    #   notices >> "Explanation translation for this locale did not exist. Created one during update."
    # end

    ActiveRecord::Base.transaction do
      begin
        @tree_tree.save!
        @reciprocal_tree_tree.save!
        # @explanation_translation.save!
      rescue ActiveRecord::StatementInvalid => e
        errors << e
      end
    end

    if errors.length > 0
      flash[:alert] = "Errors prevented the connection from being updated: #{errors.to_s}"
    else
      notices << "Updated relationship: \
      #{@tree_tree.tree_referencer.subject.code}.#{@tree_tree.tree_referencer.code} \
      #{translate('trees.labels.relation_types.' + tree_tree_params[:relationship]) } \
      #{@tree_tree.tree_referencee.subject.code}.#{@tree_tree.tree_referencee.code}." if tree_tree_params[:relationship]
      flash[:notice] = notices.to_s
    end
    respond_to do |format|
        format.json {render json: { status: 'done'}}
    end
  end #end of UPDATE def

  private

  def tree_tree_params
    params.require(:tree_tree).permit(
      :id,
      :tree_referencer_id,
      :tree_referencee_id,
      :relationship,
      :explanation,
      :active
    )
  end

  def find_tree_tree
    @tree_tree = TreeTree.find(params[:id])
  end

  # Sets @reciprocal_tree_tree to a TreeTree or nil
  def set_reciprocal_tree_tree
    if @tree_tree
      @reciprocal_tree_tree = TreeTree.where(
        :tree_referencer_id => @tree_tree[:tree_referencee_id],
        :tree_referencee_id => @tree_tree[:tree_referencer_id]).first
    else
      @reciprocal_tree_tree = nil
    end
  end

  # Sets @explanation_translation to a string or nil
  def set_explanation_translation
    if @tree_tree
      @explanation_translation = Translation.where(
        :locale => @locale_code,
        :key => @tree_tree[:explanation_key]).first
    else
      @explanation_translation = nil
    end
  end

end