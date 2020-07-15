# <!-- Supporting Resources Table -->
# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         table_partial_name: str,
#         expandable : Boolean,
#         code: Integer,
#         depth: nil || Integer,
#         num_rows: Integer,
#         by_resource_code: {
#           resourceCode1 : {
#             label_transl_key: str,
#             content_array : [
#               {
#                 rec: rec,
#                 label_key: nil,
#                 transl_key: str,
#                 detail_href: nil || path
#                 edit: nil || { path, options: {} },
#                 delete: nil || { path, options: {} },
#               },
#               {...}
#             ],
#             add: nil || {path, options: {}},
#           }
#         }
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->


# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         expandable : Boolean,
#         code: Integer,
#         depth: nil || Integer,
#         num_rows: Integer,
#         headers_array: [{
#             parent_transl_key: nil || str,
#             transl_key: str,
#             add: nil || {path, options: {}},
#             class: Class # (for cancan)
#           }]
#         content_array: [
#             {
#               rec: rec,
#               label_key: nil,
#               transl_key: str,
#               detail_href: nil || path
#               edit: nil || { path, options: {} },
#               delete: nil || { path, options: {} },
#             },
#             {...}
#           ]
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->


# <!--
#   Simple header Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     local:
#       table: {
#         headers_array: [{  //should only have one entry for partial
#             transl_key: str,
#           }]
#         content_array: [ //should only have one entry for partial
#             {
#               rec: rec,
#               transl_key: str,
#               detail_href: nil || path
#               edit: nil || { path, options: {} },
#               delete: nil || { path, options: {} },
#             },
#             {...}
#           ]
#       }
# -->

# <!--
#   Generic Table, can be used to build expandable header tables (set expandable to true), or tables as part of the main section of the detail page.
#     locals:
#       table: {
#         tree: treeRec,
#         num_rows: Integer,
#         headers_array: [{
#             parent_transl_key: nil || str,
#             transl_key: str,
#             add: nil || {path, options: {}}, //only set for first header
#             class: Class # (for cancan)
#           }]
#         content_array: [ //should be sorted by subject_id of rec
#             {
#               rec: rec, #build this info, don't just pass a record
#               edit: nil || {
#                 path: edit_tree_path(@tree.id, tree: { edit_type: 'treetree', attr_id: r[:ttid]}),
#                 options: {:remote => true, :class => "fa-lg pull-right", 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'},
#               },
#               delete: {
#                 path: tree_path(@tree.id, tree: { edit_type: 'treetree', attr_id: r[:ttid], active: false}, tree_tree: {active: false}),
#                 options: {:class => "fa-lg pull-right", 'data-confirm' => I18n.t('app.labels.confirm_deactivate', item: I18n.t("trees.labels.#{subj}") + ": " + r[:code]), method: :patch}
#               }
#             },
#             {...}
#           ]
#             - shuffle contents_array into left-to-right order while building data.
#             e.g., if col_nums = 3, we alternate content types (each type has its own column) in the content_array:
#             [{type1 item}, {type2 item}, {type3 item}, {type1 item}, {...}, ...]
#       }
# -->

class TreeTypeConfig < BaseRec

  #recognized values for the TreeTypeConfig.page_name field
  TREE_DETAIL_NAME = 'tree_detail_page' #this is the tree show page

  #recognized values for the TreeTypeConfig.config_div_name field
  HEADERS = "headers"
  TABLES = "tables"

  #TreeTypeConfig fields:
  # tree_type_id
  # version_id
  # page_name
  # config_div_name
  # table_sequence
  # col_sequence
  # field_header_key
  # tree_depth (nil if source_class != tree)
  # item_lookup (nil if not looking up connected items)
  # resource_code (nil if not looking up a resource)
  # table_partial_name
  #

  def build_detail(treeTypeRec, versionRec, subjectRec, gradeBandRec, sourceData, hierarchies, treeRec)
    #if looking up a resource, headerObj should contain resource_code
    content = []
    header = {}
    translKeys = []
    link_options = {
      popup: {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
    }
    urls = Rails.application.routes.url_helpers

    if tree_depth
      if resource_code
        header[:transl_key] = Resource.get_type_key(treeTypeRec.code, versionRec.code, resource_code)
        header[:add] = { path: "#" }
        header[:resource_code] = resource_code
        sourceData[:resourcesByCode][resource_code].each do |r|
          name_key = r.name_key
          content << {
              rec: sourceData[:joinByResourceId][r.id],
              transl_key: name_key,
              delete: { path: "#" },
              edit: { path: "#" }
            }
          translKeys << name_key
        end #sourceData[:resourcesByCode][resource_code].each do |r|
      elsif item_lookup
      else
        header_key = treeTypeRec.hierarchy_name_key(hierarchies[tree_depth])
        content_key = sourceData[:rec].name_key
        tree_params = (sourceData[:rec].id == treeRec.id) ? { edit_type: 'outcome' } : { edit_type: 'tree', attr_id: sourceData[:rec].id }
        header[:transl_key] = header_key
        content = {
          transl_key: content_key,
          edit: {
            path: urls.edit_tree_path(id: treeRec.id, tree: tree_params),
            options: link_options[:popup]
          }
        }
        translKeys << header_key
        translKeys << content_key
      end #if resource_code or item_lookup or else
    end #if tree_depth && resource_code

    return [content, header, translKeys]
  end


  # Take an array of all of the TreeTypeConfig recs with matching 'page_name'
  # Build the json object that will feed the partials of the page, and collect
  # translation keys for all translations that will be needed to display the data.
  # return an array with the page JSON object and the array of translation keys.
  def self.build_page(configArray, treeRec, treeTypeRec, versionRec, subjectRec, gradeBandRec)
    pageJSON = Hash.new { |h, k| h[k] =  {}}
    translKeys = []
    treesDataByDepth = treeRec ? self.tree_and_parents_data_by_depth(treeRec) : {}
    hierarchies = treeTypeRec.hierarchy_codes.split(",")
    configArray.each do |c|
      contentArr, header, keys = c.build_detail(treeTypeRec, versionRec, subjectRec, gradeBandRec, treesDataByDepth[c.tree_depth], hierarchies, treeRec)
      translKeys.concat(keys)
      self.add_to_pageJSON(pageJSON, c, contentArr, header, treeRec)
    end
    return [pageJSON, translKeys]
  end

  private

    def self.add_to_pageJSON(pageJSON, config, contentArr, header, tree)
      if pageJSON[config.config_div_name][config.table_sequence].nil?
        pageJSON[config.config_div_name][config.table_sequence] = {
          table_partial_name: config.table_partial_name,
          expandable: self.is_table_expandable?(config),
          code: config.table_sequence,
          depth: config.tree_depth,
          num_cols: 0,
          headers_array: [],
          content_array: [],
        }
      end
      pageJSON[config.config_div_name][config.table_sequence][:num_cols] += 1
      pageJSON[config.config_div_name][config.table_sequence][:content_array] << contentArr
      pageJSON[config.config_div_name][config.table_sequence][:headers_array] << header
    end

    def self.is_table_expandable?(config)
      return (config.config_div_name == 'headers' && config.table_partial_name == 'generic_table')
    end

    def self.tree_and_parents_data_by_depth(treeRec)
      treesByDepth = {}
      treeRec.getAllParents.concat([treeRec]).each do |t|
        temp = {
          rec: t,
          dimTreeByDimId: {},
          joinByResourceId: {},
          sectTreeBySectId: {},
          tTreeByReferenceeId: {},
          treeReferenceesAssoc: [],
          dimsByCode: Hash.new { |h, k| h[k] = [] },
          resourcesByCode: Hash.new { |h, k| h[k] = [] },
          sectorTreesAssoc: [],
        }
        if t
          t.dim_trees.map { |dt| temp[:dimTreeByDimId][dt.dimension_id] = dt }
          t.resource_joins.map { |rj| temp[:joinByResourceId][rj.resource_id] = rj }
          t.sector_trees.map { |st| temp[:sectTreeBySectId][st.sector_id] = st }
          if t[:id] == treeRec[:id]
            treeTrees = TreeTree.where(tree_referencer_id: t.id)
            treeTrees.map { |tt| temp[:tTreeByReferenceeId][tt.tree_referencee_id] = tt }
            temp[:treeReferenceesAssoc] = Tree.where(id: treeTrees.pluck('tree_referencee_id')) if (treeTrees.count > 0)
          end
          t.dimensions.map { |d| temp[:dimsByCode][d.dim_code] << d } if temp[:dimTreesByDimId].present?
          t.resources.map { |r| temp[:resourcesByCode][r.resource_code] << r } if temp[:joinsByResourceId].present?
          temp[:sectorTreesAssoc] = t.sectors if temp[:sectTreesBySectId].present?

          treesByDepth[t[:depth]] = temp
        end
      end
      return treesByDepth
    end
end