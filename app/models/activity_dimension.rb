class ActivityDimension < BaseRec
  belongs_to :activity
  belongs_to :dimension
  before_save :copy_dim_code

  def self.build_generic_column(treeType, version, dim_code, resourceable, joins, dimensions)
    urls = Rails.application.routes.url_helpers
    popup_options = {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
    translKeys = [Dimension.get_dim_type_key(dim_code, treeType.code, version.code)]
    header = {transl_key: Dimension.get_dim_type_key(dim_code, treeType.code, version.code)}
    content = []
    joinsByDimId = Hash[joins.map { |j| [j.dimension_id, j] }]
    dimensions.each do |d|
      content << {
          rec: joinsByResourceId[d.id],
          transl_key: d.get_dim_name_key,
          # delete: { path: "#" },
          # edit: { path: urls.edit_resource_path(id: r.id), options: popup_options }
      }
      translKeys << d.get_dim_name_key
    end
    # No dimensions with this dim_code
    # currently attached to the Tree at tree_depth
    if (content.length == 0)
      content << {
        rec: ActivityDimension.new(activity: resourceable, dimension: Dimension.new),
        transl_key: nil,
        # edit: { path: urls.new_resource_path(
        #     resource: { resource_code: resource_code, resourceable_id: resourceable.id, resourceable_type: resourceable.class.to_s, user_id: user_id },
        #   ),
        # options: popup_options }
      }
    end
    return [
      header,
      content,
      translKeys
    ]
  end

  def self.build_generic_table(treeType, version, dim_codes, resourceable, joins, dimsByCode)
    table = Hash.new { |h, k| h[k] = [] }
    translKeys = []
    depths = { 'LessonPlan': 0, 'Activity': 2 }
    table[:table_partial_name] = 'trees/show/generic_table'
    table[:expandable], table[:depth] = [false, depths[:"#{resourceable.class.to_s}"]]
    dim_codes.each do |code|
      if treeType.dim_codes.include?(code)
	      header, content, keys = build_generic_column(treeType, version, code, resourceable, joins, dimsByCode[code])
	      table[:headers_array] << header
	      table[:content_array] << content
	      translKeys.concat(keys)
	  end
    end
    no_content = table[:content_array].length > 0 ? false : true
    return no_content ? [nil, nil] : [table, translKeys]
  end

	private
	  def copy_dim_code
	    self.dim_code = dimension.dim_code
	  end
end