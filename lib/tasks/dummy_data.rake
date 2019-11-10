# dummy_data.rake
namespace :dummy_data do

  desc "create dummy data after bio 9 and che 9 load (must run bio 9, then chem 9, then run this)"
  task create: :environment do

    bio = Subject.where(code: 'bio').first
    che = Subject.where(code: 'che').first
    phy = Subject.where(code: 'phy').first
    bio9111 = Tree.where(base_key: "TFV.v01.bio.9.1.1.1").first
    che9111 = Tree.where(base_key: "TFV.v01.che.9.1.1.1").first
    sector3 = Sector.where(name_key: "sector.3.name").first
    sector4 = Sector.where(name_key: "sector.4.name").first
    sector6 = Sector.where(name_key: "sector.6.name").first
    sector8 = Sector.where(name_key: "sector.8.name").first

    puts "sector 3 relation"
    SectorTree.create!(
      sector_id: sector3.id,
      tree_id: bio9111.id,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.3.expl"
    )
    Translation.create!(
      locale:'en',
      key: "TFV.v01.bio.9.1.1.1.sector.3.expl",
      value: "Ne dolor utroque admodum eum."
    )

    puts "sector 4 relation"
    SectorTree.create!(
      sector_id: sector4.id,
      tree_id: bio9111.id,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.4.expl"
    )
    # if errors.count > 0
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.4.expl",
      value: "Lorem ipsum dolor sit amet, ipsum inermis eam id, vim nonumy adolescens eu."
    )

    puts "sector 6 relation"
    SectorTree.create!(
      sector_id: sector6.id,
      tree_id: bio9111.id,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.6.expl"
    )
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.6.expl",
      value: "Modus sonet equidem ne has, usu at habeo cetero tritani, nec id dolor putent admodum."
    )

    puts "sector 8 relation"
    SectorTree.create!(
      sector_id: sector8.id,
      tree_id: bio9111.id,
      explanation_key: "TFV.v01.bio.9.1.1.1.sector.8.expl"
    )
    Translation.create!(
      locale: 'en',
      key: "TFV.v01.bio.9.1.1.1.sector.8.expl",
      value: "Pri ut ferri labore eleifend, dicit detracto vix an."
    )

    puts "misconception 1"
    Dimension.create!(
      subject_id: phy.id,
      dim_type: Dimension::MISCONCEPTION,
      dim_name_key: 'dim_miscon_fall_faster',
      dim_desc_key: 'dim_miscon_fall_faster_desc'
    )
    Translation.create!(
      locale: 'en',
      key: "dim_miscon_fall_faster",
      value: "A heavier ball will fall faster than a lighter one."
    )
    Translation.create!(
      locale: 'en',
      key: "dim_miscon_fall_faster_desc",
      value: "A heavier ball will fall faster than a lighter one."
    )

    puts "misconception 2"
    Dimension.create!(
      subject_id: phy.id,
      dim_type: Dimension::MISCONCEPTION,
      dim_name_key: 'dim_miscon_warm_summer',
      dim_desc_key: 'dim_miscon_warm_summer_desc'
    )
    Translation.create!(
      locale: 'en',
      key: "dim_miscon_warm_summer",
      value: "Summer is warmer because the Earth is closer to the Sun at that time."
    )
    Translation.create!(
      locale: 'en',
      key: "dim_miscon_warm_summer_desc",
      value: "Summer is warmer because the Earth is closer to the Sun at that time."
    )

    puts "Big Idea 1"
    Dimension.create!(
      subject_id: bio.id,
      dim_type: Dimension::BIG_IDEA,
      dim_name_key: 'dim_bigidea_cells_fundamental',
      dim_desc_key: 'dim_bigidea_cells_fundamental_desc'
    )
    Translation.create!(
      locale: 'en',
      key: "dim_bigidea_cells_fundamental",
      value: "Cells are the basic unit of structure and function in organisms."
    )
    Translation.create!(
      locale: 'en',
      key: "dim_bigidea_cells_fundamental_desc",
      value: "Cells are the basic unit of structure and function in organisms."
    )

    puts "Big Idea 2"
    Dimension.create!(
      subject_id: che.id,
      dim_type: Dimension::BIG_IDEA,
      dim_name_key: 'dim_bigidea_matter_fundamental',
      dim_desc_key: 'dim_bigidea_matter_fundamental_desc'
    )
    Translation.create!(
      locale: 'en',
      key: "dim_bigidea_matter_fundamental",
      value: "The material of which the universe is composed exists in different states which have uniqe properties."
    )
    Translation.create!(
      locale: 'en',
      key: "dim_bigidea_matter_fundamental_desc",
      value: "The material of which the universe is composed exists in different states which have uniqe properties."
    )

    # "Pri ut ferri labore eleifend, dicit detracto vix an."
    # "Impedit persequeris eos ea."
  end

end




