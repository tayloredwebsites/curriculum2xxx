# dummy_data.rake
namespace :dummy_data do

  desc "create dummy data after bio 9 and che 9 load (must run bio 9, then chem 9, then run this)"
  task create: :environment do

    puts "sector 3 relation"
    SectorTree.create!(
      sector_id: 3,
      tree_id: 4,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.3.expl"
    )
    Translation.create!(
      locale:'en',
      key: "TFV.v01.bio.9.1.1.1.sector.3.expl",
      value: "Ne dolor utroque admodum eum."
    )

    puts "sector 4 relation"
    SectorTree.create!(
      sector_id: 4,
      tree_id: 4,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.4.expl"
    )
    # if errors.count > 0
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.4.expl",
      value: "Lorem ipsum dolor sit amet, ipsum inermis eam id, vim nonumy adolescens eu."
    )

    puts "sector 6 relation"
    st = SectorTree.create!(
      sector_id: 6,
      tree_id: 4,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.6.expl"
    )
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.6.expl",
      value: "Modus sonet equidem ne has, usu at habeo cetero tritani, nec id dolor putent admodum."
    )

    puts "sector 8 relation"
    SectorTree.create!(
      sector_id: 8,
      tree_id: 4,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.8.expl"
    )
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.8.expl",
      value: "Pri ut ferri labore eleifend, dicit detracto vix an."
    )

    puts "bio 4 akin che 59"
    TreeTree.create!(
      tree_referencer_id: 4,
      tree_referencee_id: 59,
      relationship: 'akin',
      explanation_key: 'TFV.v01.bio.9.1.1.1.tree.59'
    )
    Translation.create!(
      locale:'en',
      key: 'TFV.v01.bio.9.1.1.1.tree.59',
      value: "Nihil lobortis platonem est ei, ut sit prompta veritus."
    )

    puts "che 59 akin bio 4"
    TreeTree.create!(
      tree_referencer_id: 59,
      tree_referencee_id: 4,
      relationship: 'akin',
      explanation_key: 'TFV.v01.che.9.1.1.1.tree.4'
    )
    Translation.create!(
      locale:'en',
      key: 'TFV.v01.che.9.1.1.1.tree.4',
      value: "Nihil lobortis platonem est ei, ut sit prompta veritus."
    )

    puts "bio 4 applies che 166"
    TreeTree.create!(
      tree_referencer_id: 4,
      tree_referencee_id: 166,
      relationship: 'applies',
      explanation_key: 'TFV.v01.bio.9.1.1.1.tree.166'
    )
    Translation.create!(
      locale:'en',
      key: 'TFV.v01.bio.9.1.1.1.tree.166',
      value: "Impedit persequeris eos ea."
    )

    puts "che 166 depends bio 4"
    TreeTree.create!(
      tree_referencer_id: 166,
      tree_referencee_id: 4,
      relationship: 'depends',
      explanation_key: 'TFV.v01.che.9.5.1.1.tree.4'
    )
    Translation.create!(
      locale:'en',
      key: 'TFV.v01.che.9.5.1.1.tree.4',
      value: "Impedit persequeris eos ea."
    )


  end

end




