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
      outcome_depth: 2,
      version_id: @v02.id,
      working_status: true,
      miscon_dim_type: 'miscon',
      big_ideas_dim_type: 'bigidea',
      ess_q_dim_type: 'essq',
      tree_code_format: 'grade,unit,sub_unit,comp',
      detail_headers: 'grade,unit,(sub_unit),comp,[subj_big_idea],[ess_q],{explain},[miscon],[sector],[connect],[refs]',
      grid_headers: 'grade,unit,(sub_unit),comp,[subj_big_idea],[ess_q],explain,[miscon],[connect],[refs]'

    }
    if myTreeType.count < 1
      raise 'Missing Tree Type record for tfv v02'
    else
      TreeType.update(myTreeType.first.id, myTreeTypeValues)
    end
    throw "Invalid Tree Type Count" if TreeType.where(code: 'tfv').count != 2
    @tfv = TreeType.where(code: 'tfv', version_id: @v02.id).first

    puts "Curriculum (Tree Type) is updated for tfv "
    puts "  Updated Curriculum: #{@tfv.code} with Hierarchy: #{@tfv.hierarchy_codes}"

    STDOUT.puts 'Create all Outcome records for all tree records at the outcome level.'
    Tree.all.each do |t|
      tt = t.tree_type
      if tt.outcome_depth > 0
        if t.depth == tt.outcome_depth && t.outcome_id != nil
          out = Outcome.new()
          out.set_base_key(t.base_key)
          out.save
          t.outcome_id = out.id
          t.save
        end
      end
    end
    STDOUT.puts 'Done: Outcome records for all tree records at the outcome level have been created.'

  end #update_tree_type


end
