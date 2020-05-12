# seed_turkey.rake
namespace :seed_turkey_v02a do

  task populate: [:update_tree_type]

  ###################################################################################
  desc "update the Curriculum Tree Type and Version"
  task update_tree_type: :environment do

    # reference version record from seeds.rb
    myVersion = Version.where(:code => 'v02')
    if myVersion.count > 0
      @v02 = myVersion.first
    else
      raise 'missing version 2 record'
    end

    # create Tree Type record for the Curriculum
    myTreeType = TreeType.where(code: 'tfv', version_id: @v02.id)
    myTreeTypeValues = {
      code: 'tfv',
      hierarchy_codes: 'grade,unit,sub_unit,comp',
      valid_locales: BaseRec::LOCALE_EN+','+BaseRec::LOCALE_TR,
      sector_set_code: 'future,hide',
      sector_set_name_key: 'sector.set.future.name',
      curriculum_title_key: 'curriculum.tfv.title', # 'Turkey STEM Curriculum'
      outcome_depth: 3,
      version_id: @v02.id,
      working_status: true,
      # [dim code]_dim_type fields deprecated in favor of dim_codes
      # miscon_dim_type: 'miscon',
      # big_ideas_dim_type: 'bigidea',
      # ess_q_dim_type: 'essq',
      dim_codes: 'essq,bigidea,pract,miscon',
      tree_code_format: 'subject,grade,unit,sub_unit,comp',
      detail_headers: 'grade,unit,(sub_unit),comp,<essq<,>bigidea>,[pract],{explain},[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,(sub_unit),comp,[essq],[bigidea],[pract],{explain},[miscon]'
    }
    if myTreeType.count < 1
      raise 'Missing Tree Type record for tfv v02'
    else
      myTreeType = TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'tfv').count != 2
    @tfv = TreeType.where(code: 'tfv', version_id: @v02.id).first

    puts "Curriculum (Tree Type) is updated for tfv "
    puts "  Updated Curriculum: #{@tfv.code} with Hierarchy: #{@tfv.hierarchy_codes}"

    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Dimension.get_dim_type_key(myTreeType.ess_q_dim_type, myTreeType.code, @v02.code), 'K-12 Big Ideas')
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    # STDOUT.puts 'Create translation record for Essential Questions as K-12 Big Ideas.'

    # rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, Dimension.get_dim_type_key(myTreeType.big_ideas_dim_type, myTreeType.code, @v02.code), 'Specific Big Ideas')
    # throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    # STDOUT.puts 'Create translation record for Big Ideas as Specific big ideas.'

    # Create translation(s) for hierarchy codes
    rec, status, message = Translation.find_or_update_translation(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.sub_unit', 'Sub-Unit')
    throw "ERROR updating sector translation: #{message}" if status == BaseRec::REC_ERROR
    STDOUT.puts 'Create translation record for Sub-Unit.'

    # STDOUT.puts 'Create all Outcome records for all tree records at the outcome level.'
    # Tree.all.each do |t|
    #   tt = t.tree_type
    #   if tt.outcome_depth > 0
    #     # Tree model overrides the depth field. Returns the length of the code.
    #     if t.depth == tt.outcome_depth + 1 && !t.outcome_id.present?
    #       puts "try to save outcome for #{t.code}"
    #       out = Outcome.new()
    #       out.base_key = out.get_base_key(t.base_key)
    #       out.save
    #       t.outcome_id = out.id
    #       t.save
    #       puts "saved outcome for #{t.code}"
    #     end
    #   end
    # end
    # STDOUT.puts 'Done: Outcome records for all tree records at the outcome level have been created.'

    # Tree.joins(:outcome).where(:tree_type_id => 2).each do |t|
    #   old_name_key = t.buildNameKey
    #   code_arr = t.code.split(".")
    #   t.code = code_arr.insert(code_arr.length - 1, "").join(".")
    #   t.save
    #   new_name_key = t.buildNameKey
    #   Translation.where(:key => old_name_key).each do |tr|
    #     tr.key = new_name_key
    #     tr.save
    #   end
    #   puts "saved new code for #{t.code}"
    # end

  end #update_tree_type


end
