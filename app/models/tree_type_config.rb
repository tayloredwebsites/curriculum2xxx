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
  DIM_DETAIL_PREFIX = 'dim_detail_' #add dim_code to end: e.g., "dim_detail_miscon"

  #recognized values for the TreeTypeConfig.config_div_name field
  HEADERS = "headers"
  TABLES = "tables"

  # recognized values for item_lookup,
  # other than model names.
  WEEKS = "duration_weeks"
  HOURS = "hours_per_week"


  def self.dim_page_name(dim_code)
    return "#{DIM_DETAIL_PREFIX}#{dim_code}"
  end
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


  def build_detail(treeTypeRec, versionRec, subjectRec, gradeBandRec, sourceData, hierarchies, subjectsById, treeRec)
    #if looking up a resource, headerObj should contain resource_code
    content = []
    header = {}
    translKeys = []
    link_options = {
      popup: {:remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'},
      popup_pull_right: {:class => "fa-lg pull-right", :remote => true, 'data-toggle' =>  "modal", 'data-target' => '#modal_popup'}
    }
    urls = Rails.application.routes.url_helpers
    no_content = false
    dim_item_lookup = item_lookup ? item_lookup.split("&")[0] : item_lookup
    if resource_code
      #building data for Resources attached to any Resourceable.
      #Could be attached directly to a Tree on the TREE DETAIL page,
      #or could be attached to a Dimension/Outcome displayed on
      #that page.
      resource_title_key = Resource.get_type_key(treeTypeRec.code, versionRec.code, resource_code)
      header[:resource_code] = resource_code
      translKeys << resource_title_key
    end
    if tree_depth
    #everything on the TREE_DETAIL_PAGE will have a tree depth
      if (item_lookup == 'ResourceJoin' || item_lookup == 'Outcome') && resource_code && sourceData
      #build data for Resource attached directly to a Tree
        header[:transl_key] = resource_title_key
        # header[:add] = { path: "#" }
        sourceData[:resourcesByCode][resource_code].each do |r|
          content << {
              rec: sourceData[:joinByResourceId][r.id],
              transl_key: r.name_key,
              # delete: { path: "#" },
              edit: { path: urls.edit_resource_path(id: r.id), options: link_options[:popup] }
            }
          translKeys << r.name_key
        end #sourceData[:resourcesByCode][resource_code].each do |r|
        content << nil if (content.length == 0)
      elsif sourceData && treeTypeRec.dim_codes.split(',').include?(dim_item_lookup)
      #build data for Dimensions attached to a tree
      #also build data for Resources attached to a tree through the Dimensions
        dim_type_name = Dimension.get_dim_type_key(dim_item_lookup, treeTypeRec.code, versionRec.code)
        header[:transl_key] = resource_code ? resource_title_key : dim_type_name
        header[:parent_transl_key] = dim_type_name if resource_code
        # header[:add] = { path: "#" }
        translKeys << header[:transl_key]
        translKeys << header[:parent_transl_key] if resource_code
        sourceData[:dimsByCode][dim_item_lookup].each do |r|
          if resource_code
          # build data for the Resources attached to the Dimensions,
          # rather than the Dimensions themselves
            r.resources.where(resource_code: resource_code).each do |res|
              content << {
                rec: res,
                transl_key: res.name_key
              }
              translKeys << res.name_key
            end
          else
          # build Data for the Dimensions attached to the tree
          # stored as sourceData[:rec]
            content << {
                rec: sourceData[:dimTreeByDimId][r.id],
                transl_key: r.get_dim_name_key,
                detail_href: item_lookup.split("&").length > 1 ? urls.dimension_path(id: r.id) : nil,
                delete: {
                  path: urls.tree_path(id: treeRec.id, tree: { edit_type: 'dimtree', attr_id: sourceData[:dimTreeByDimId][r.id].id, active: false}, sector_tree: {active: false}),
                  options: link_options[:confirm_patch]
                },
              }
            translKeys << r.get_dim_name_key
          end
        end #sourceData[:resourcesByCode][resource_code].each do |r|
        # if no Dimensions or Dimension Resources are attached to
        # the sourceData[:rec] tree, add nil to the content array as a
        # spacer.
        content << nil if (content.length == 0)
      elsif item_lookup && sourceData
      #non-dimension ITEM LOOKUPS
        case item_lookup
        when "Sector"
          #build data for Sectors attached directly to a Tree
          header[:transl_key] = treeTypeRec.sector_set_name_key
          translKeys << header[:transl_key]
          header[:add] = {
              path: urls.edit_tree_path(id: treeRec.id, tree: { edit_type: 'sector', attr_id: 'new'}),
              options: link_options[:popup]
            }
          sourceData[:sectorsAssoc].each do |r|
            content << {
                rec: sourceData[:sectTreeBySectId][r.id],
                transl_key: r.get_name_key,
                delete: {
                  path: urls.tree_path(id: treeRec.id, tree: { edit_type: 'sector', attr_id: sourceData[:sectTreeBySectId][r.id].id, active: false}, sector_tree: {active: false})
                },
                # edit: { path: urls.edit_resource_path(id: r.id), options: link_options[:popup] }
              }
            translKeys << r.get_name_key
          end #sourceData[:sectorTreesAssoc].each do |r|
          content << nil if (content.length == 0)
        when "TreeTree"
          #build data for Learning Outcome (Trees) attached to this Tree
          header[:transl_key] = "not used"
          sourceData[:treeReferenceesAssoc].each do |r|
            tt = sourceData[:tTreeByReferenceeId][r.id]
            subj = subjectsById[r.subject_id]
            format_code = r.format_code
            content << {
                rec: r,
                format_code: format_code,
                subj_code: subj.code,
                subj_key: subj.get_versioned_name_key,
                rel_code: tt.relationship,
                rel: I18n.translate("trees.labels.relation_types.#{tt.relationship}"),
                transl_key: r.name_key,
                delete: {
                  path: urls.tree_path(id: treeRec.id, tree: { edit_type: 'treetree', attr_id: tt.id, active: false}, tree_tree: {active: false}),
                  options: {:class => "fa-lg pull-right", 'data-confirm' => I18n.t('app.labels.confirm_deactivate', item: I18n.t("trees.labels.#{subj.code}") + ": " + format_code), method: :patch}
                },
                edit: {
                  path: urls.edit_tree_path(id: treeRec.id, tree: { edit_type: 'treetree', attr_id: tt.id}),
                  options: link_options[:popup_pull_right]
                }
              }
            translKeys << r.name_key
            translKeys << subjectsById[r.subject_id].get_versioned_name_key
          end #sourceData[:sectorTreesAssoc].each do |r|
          content << nil if (content.length == 0)
        when "Subject"
          header[:text] = "<strong>#{I18n.t('app.labels.subject')}:</strong>"
          content = { rec: subjectsById[treeRec.subject_id], transl_key: subjectsById[treeRec.subject_id].get_versioned_name_key }
          translKeys << content[:transl_key]
        when WEEKS
          if sourceData[:outcomeRec]
            header[:text] = I18n.t('trees.labels.duration_weeks_html', weeks: sourceData[:outcomeRec].duration_weeks)
            content = {
              rec: sourceData[:outcomeRec],
              edit: {
                path: urls.edit_tree_path(id: treeRec.id, tree: { edit_type: WEEKS }),
                options: link_options[:popup]
              }
            }
          else
            no_content = true
          end
        when HOURS
          if sourceData[:outcomeRec]
            header[:text] = I18n.t('trees.labels.hours_per_week_html', hours: sourceData[:outcomeRec].hours_per_week)
            content = {
              rec: sourceData[:outcomeRec],
              edit: {
                path: urls.edit_tree_path(id: treeRec.id, tree: { edit_type: HOURS }),
                options: link_options[:popup]
              }
            }
          else
            no_content = true
          end
        end
      elsif sourceData
        tree_params = (sourceData[:rec].id == treeRec.id) ? { edit_type: 'outcome' } : { edit_type: 'tree', attr_id: sourceData[:rec].id }
        header[:transl_key] = treeTypeRec.hierarchy_name_key(hierarchies[tree_depth])
        content = {
          rec: sourceData[:rec],
          transl_key: sourceData[:rec].name_key,
          edit: {
            path: urls.edit_tree_path(id: treeRec.id, tree: tree_params),
            options: link_options[:popup]
          }
        }
        translKeys << header[:transl_key]
        translKeys << content[:transl_key]
      else
      # no sourceData means there is no parent tree at this depth
      # e.g., may be skipping an optional sub-unit
      no_content = true
      end #if resource_code or item_lookup or else
    end #if tree_depth && resource_code
    if no_content
      return [nil, nil, nil]
    else
      return [content, header, translKeys]
    end
  end


  # Take an array of all of the TreeTypeConfig recs with matching 'page_name'
  # Build the json object that will feed the partials of the page, and collect
  # translation keys for all translations that will be needed to display the data.
  # return an array with the page JSON object and the array of translation keys.
  def self.build_page(configArray, rec, treeTypeRec, versionRec, subjectRec, gradeBandRec)
    pageJSON = Hash.new { |h, k| h[k] =  {}}
    translKeys = []
    treesDataByDepth = rec.class.to_s == "Tree" ? self.tree_and_parents_data_by_depth(rec) : {}
    resourcesByCode = rec.class.to_s == "Dimension" ? self.resources_by_code(rec) : {}
    hierarchies = treeTypeRec.hierarchy_codes.split(",")
    subjectsById = Hash[Subject.where(tree_type_id: treeTypeRec.id).map { |s| [s.id, s] }]
    configArray.each do |c|
      data = (rec.class.to_s == "Tree") ? treesDataByDepth[c.tree_depth] : resourcesByCode
      contentArr, header, keys = c.build_detail(treeTypeRec, versionRec, subjectRec, gradeBandRec, data, hierarchies, subjectsById, rec)
      translKeys.concat(keys) if !keys.nil?
      self.add_to_pageJSON(pageJSON, c, contentArr, header, rec) if !header.nil?
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
          tree: tree,
        }
      end
      pageJSON[config.config_div_name][config.table_sequence][:num_cols] += 1
      pageJSON[config.config_div_name][config.table_sequence][:content_array] << contentArr
      pageJSON[config.config_div_name][config.table_sequence][:headers_array] << header
    end

    def self.is_table_expandable?(config)
      return (config.config_div_name == HEADERS && config.table_partial_name == 'generic_table')
    end

    def self.resources_by_code(resourceableRec)
      temp = Hash.new { |h, k| h[k] = [] }
      temp[:joinByResourceId] = {}
      joins = resourceableRec.resource_joins.active
      resource_ids = joins.pluck('resource_id')
      joins.map { |j| temp[:joinByResourceId][j.resource_id] =  j }
      Resource.where(id: resource_ids).map { |r| temp[r.resource_code] = r }
      return temp
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
          sectorsAssoc: [],
        }
        if t
          tree_joins = t.resource_joins.active
          resource_ids = tree_joins.pluck("resource_id")
          t.dim_trees.map { |dt| temp[:dimTreeByDimId][dt.dimension_id] = dt }
          tree_joins.map { |rj| temp[:joinByResourceId][rj.resource_id] = rj }
          sectorTrees = t.sector_trees.active
          sectorTrees.map { |st| temp[:sectTreeBySectId][st.sector_id] = st }
          if t[:id] == treeRec[:id]
            treeTrees = TreeTree.active.where(tree_referencer_id: t.id)
            outc_joins = t.outcome.resource_joins.active
            resource_ids.concat(outc_joins.pluck("resource_id"))
            treeTrees.map { |tt| temp[:tTreeByReferenceeId][tt.tree_referencee_id] = tt }
            temp[:treeReferenceesAssoc] = Tree.where(id: treeTrees.pluck('tree_referencee_id')) if (treeTrees.count > 0)
            temp[:outcomeRec] = t.outcome
            outc_joins.map { |rj| temp[:joinByResourceId][rj.resource_id] = rj }
          end
          t.dimensions.map { |d| temp[:dimsByCode][d.dim_code] << d } if temp[:dimTreeByDimId].present?
          Resource.where(id: resource_ids).map { |r| temp[:resourcesByCode][r.resource_code] << r } if temp[:joinByResourceId].present?
          temp[:sectorsAssoc] = Sector.where(id: sectorTrees.pluck("sector_id")) if temp[:sectTreeBySectId].present?

          treesByDepth[t[:depth]] = temp
        end
      end
      return treesByDepth
    end
end