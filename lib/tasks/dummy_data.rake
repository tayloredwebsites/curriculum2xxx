# dummy_data.rake
namespace :dummy_data do

  desc "create dummy data after bio 9 and che 9 load (must run bio 9, then chem 9, then run this)"
  task create: :environment do

    bio = Subject.where(code: 'bio').first
    che = Subject.where(code: 'che').first
    phy = Subject.where(code: 'phy').first
    ear = Subject.where(code: 'ear').first
    bio9111 = Tree.where(base_key: "TFV.v01.bio.9.1.1.1").first
    che9111 = Tree.where(base_key: "TFV.v01.che.9.1.1.1").first
    sector3 = Sector.where(name_key: "sector.3.name").first
    sector4 = Sector.where(name_key: "sector.4.name").first
    sector6 = Sector.where(name_key: "sector.6.name").first
    sector8 = Sector.where(name_key: "sector.8.name").first

    # puts "sector 3 relation"
    # SectorTree.create!(
    #   sector_id: sector3.id,
    #   tree_id: bio9111.id,
    #   explanation_key: "TFV.v01.bio.9.1.1.1.sector.3.expl"
    # )
    # Translation.create!(
    #   locale:'en',
    #   key: "TFV.v01.bio.9.1.1.1.sector.3.expl",
    #   value: "Ne dolor utroque admodum eum."
    # )

    # puts "sector 4 relation"
    # SectorTree.create!(
    #   sector_id: sector4.id,
    #   tree_id: bio9111.id,
    #   explanation_key: "TFV.v01.bio.9.1.1.1.sector.4.expl"
    # )
    # # if errors.count > 0
    # Translation.create!(
    #   locale: 'en',
    #   key: "TFV.v01.bio.9.1.1.1.sector.4.expl",
    #   value: "Lorem ipsum dolor sit amet, ipsum inermis eam id, vim nonumy adolescens eu."
    # )

    # puts "sector 6 relation"
    # SectorTree.create!(
    #   sector_id: sector6.id,
    #   tree_id: bio9111.id,
    #   explanation_key: "TFV.v01.bio.9.1.1.1.sector.6.expl"
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "TFV.v01.bio.9.1.1.1.sector.6.expl",
    #   value: "Modus sonet equidem ne has, usu at habeo cetero tritani, nec id dolor putent admodum."
    # )

    # puts "sector 8 relation"
    # SectorTree.create!(
    #   sector_id: sector8.id,
    #   tree_id: bio9111.id,
    #   explanation_key: "TFV.v01.bio.9.1.1.1.sector.8.expl"
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "TFV.v01.bio.9.1.1.1.sector.8.expl",
    #   value: "Pri ut ferri labore eleifend, dicit detracto vix an."
    # )

    # puts "misconception 1"
    # Dimension.create!(
    #   subject_id: phy.id,
    #   dim_type: Dimension::MISCONCEPTION,
    #   dim_name_key: 'dim_miscon_fall_faster',
    #   dim_desc_key: 'dim_miscon_fall_faster_desc'
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_fall_faster",
    #   value: "A heavier ball will fall faster than a lighter one."
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_fall_faster_desc",
    #   value: "A heavier ball will fall faster than a lighter one."
    # )

    # puts "misconception 2"
    # Dimension.create!(
    #   subject_id: phy.id,
    #   dim_type: Dimension::MISCONCEPTION,
    #   dim_name_key: 'dim_miscon_warm_summer',
    #   dim_desc_key: 'dim_miscon_warm_summer_desc'
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_warm_summer",
    #   value: "Summer is warmer because the Earth is closer to the Sun at that time."
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_warm_summer_desc",
    #   value: "Summer is warmer because the Earth is closer to the Sun at that time."
    # )

    # puts "Big Idea 1"
    # Dimension.create!(
    #   subject_id: bio.id,
    #   dim_type: Dimension::BIG_IDEA,
    #   dim_name_key: 'dim_bigidea_cells_fundamental',
    #   dim_desc_key: 'dim_bigidea_cells_fundamental_desc'
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_bigidea_cells_fundamental",
    #   value: "Cells are the basic unit of structure and function in organisms."
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_bigidea_cells_fundamental_desc",
    #   value: "Cells are the basic unit of structure and function in organisms."
    # )

    # puts "Big Idea 2"
    # Dimension.create!(
    #   subject_id: che.id,
    #   dim_type: Dimension::BIG_IDEA,
    #   dim_name_key: 'dim_bigidea_matter_fundamental',
    #   dim_desc_key: 'dim_bigidea_matter_fundamental_desc'
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_bigidea_matter_fundamental",
    #   value: "The material of which the universe is composed exists in different states which have uniqe properties."
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_bigidea_matter_fundamental_desc",
    #   value: "The material of which the universe is composed exists in different states which have uniqe properties."
    # )

    # puts "misconception 3"
    # Dimension.create!(
    #   subject_id: bio.id,
    #   dim_type: Dimension::MISCONCEPTION,
    #   dim_name_key: 'dim_miscon_blue_blood',
    #   dim_desc_key: 'dim_miscon_blue_blood_desc'
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_blue_blood",
    #   value: "Blood in arteries is red because it is oxygenated and the blood in veins is blue because it is not oxygenated."
    # )
    # Translation.create!(
    #   locale: 'en',
    #   key: "dim_miscon_blue_blood_desc",
    #   value: "Blood in arteries is red because it is oxygenated and the blood in veins is blue because it is not oxygenated."
    # )

    # miscon3 = Dimension.where(dim_name_key: "dim_miscon_blue_blood").first
    # puts "miscon3.id: #{miscon3.id}"

    # puts "misconception 3 relation"
    # DimTree.create!(
    #   dimension_id: miscon3.id,
    #   tree_id: bio9111.id,
    #   dim_explanation_key: "TFV.v01.bio.9.1.1.1.miscon.3.expl"
    # )
    # Translation.create!(
    #   locale:'en',
    #   key: "TFV.v01.bio.9.1.1.1.miscon.3.expl",
    #   value: "Pri ut ferri labore eleifend, dicit detracto vix an."
    # )

    # bigidea1 = Dimension.where(dim_name_key: "dim_bigidea_cells_fundamental").first
    # puts "bigidea1.id: #{bigidea1.id}"

    # puts "bigidea 1 relation"
    # DimTree.create!(
    #   dimension_id: bigidea1.id,
    #   tree_id: bio9111.id,
    #   dim_explanation_key: "TFV.v01.bio.9.1.1.1.bigidea.1.expl"
    # )
    # Translation.create!(
    #   locale:'en',
    #   key: "TFV.v01.bio.9.1.1.1.bigidea.1.expl",
    #   value: "Impedit persequeris eos ea.."
    # )

        # dimension template
        # {
        #     :subject => ,
        #     :dim_type => ,
        #     :dim_name_key => ,
        #     :dim_desc_key => ,
        #     :text =>
        # },
    sciBiodiversity = Tree.where(:base_key => "TFV.v01.sci.5.6.1.1").first
    sciEnv = Tree.where(:base_key => "TFV.v01.sci.5.6.1.2").first
    sciFoodChain = Tree.where(:base_key => "TFV.v01.sci.8.6.1.1").first
    bioFoodEnergy = Tree.where(:base_key => "TFV.v01.bio.10.3.1.3").first
    dimensions = [
      #bio big ideas
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_bio_living_things",
        :dim_desc_key => "dim_bigidea_bio_living_things_desc",
        :text => "What do all living things have in common? How do living things’ different parts and structures work together in systems to enable them to function?",
        :desc => "Although there is incredible diversity in different forms of life, all organisms have some things in common. Students should explore the diversity of living things by answering the question ‘How are things different and how are they similar?",
        :trees => [
          {
            :lo => bio9111,
            :explanation => "In the upper grades, students ask questions like ‘How do children grow bigger?’ and ’Why do bone cells look different from skin cells in the same organism?’ to explore mitosis and cellular differentiation and ask questions such as ‘How can we survive in the cold/heat?’ to explore feedback mechanisms."
          },
          {
            :lo => sciBiodiversity,
            :explanation => "At the elementary level, students should ask the question ‘What do the different parts of organisms do?’ to explore how external parts of an organism help them perform their daily functions. As student progress in the middle years, they then need to ask the question ‘What are living things made out of?’ to build toward an understanding of a central tenet of Biology—cell theory. Students then consider ’How are different body systems interrelated?’ by comparing different kinds of cells and how they work together, and then explore how systems of specialized cells work together in bodies to perform the essential functions of life."
          }
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_bio_energy_cycle",
        :dim_desc_key => "dim_bigidea_bio_energy_cycle_desc",
        :text => "How do matter and energy cycle throughout an ecosystem? How do organisms use this matter and energy to live, grow, and reproduce?",
        :desc => "One of the most fundamental ideas of ecosystems is that matter and energy move from organism to organism and thus the different components of the organism are connected. To begin building toward an understanding of these interrelations, students at the elementary level should be facilitated to come up with the question ‘What do plants and animals need in order to live?’ guiding their learning that plants need water and sunlight to live and grow and sometimes depend on animals to transfer their pollen or seeds. Animals need to eat plants or other animals as food.",
        :trees => [
          {
            :lo => sciEnv,
            :explanation => "In later elementary school, students begin to ask, ‘Why do plants matter?’ to explore the fundamental role plants play in ecosystems. They also ask, ‘How do we use food?’ to learn that food provides animals with the materials and energy they need for growth, warmth, and motion, and that plants use their matter and energy to grow and maintain conditions necessary for survival."
          },
          {
            :lo => sciFoodChain,
            :explanation => "At the middle school level, students ask ‘How can the same atom move from one organism to another?’ They explore to build toward the idea that atoms that make up living things are cycled repeatedly through the living and non-living parts of ecosystems. They also learn that food webs model how matter and energy are transferred among producers, consumers, and decomposers. Students at this level also make connections between Biology and Chemistry by asking ‘How does chemistry help us understand how plants make their own food?’ Students examine more closely how plants use energy from light to make sugars through photosynthesis."
          },
          {
            :lo => bioFoodEnergy,
            :explanation => "At the high school level, students ask ‘How do molecules rearrange as they move through an ecosystem?’ They consider different kinds of atoms and their recombination through photosynthesis and cellular respiration, transferring energy in an ecosystem. For example, carbon journeys from CO2 to hydrocarbon backbones of sugars and then to amino acids or other molecules. Students also connect to their understanding of the conservation of matter and energy built in middle school to ask, ‘Why is such a low percentage of matter and energy transferred at each level of a food web?’ They discover that only a fraction of matter consumed at a lower level of a food web is transferred up, resulting in fewer organisms at higher levels, although matter and energy are conserved."
          }
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_bioecosystems",
        :dim_desc_key => "dim_bigidea_bioecosystems_desc",
        :text => "What happens to ecosystems and populations when there are big changes to the environment? Why don’t ecosystems and populations change more often?",
        :desc => "What happens to ecosystems and populations when there are big changes to the environment? Why don’t ecosystems and populations change more often?",
        :trees => [
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_biodiversity",
        :dim_desc_key => "dim_bigidea_biodiversity_desc",
        :text => "How is biodiversity relevant to humans and how do we affect it?",
        :desc => "How is biodiversity relevant to humans and how do we affect it?",
        :trees => [
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_bioanimals",
        :dim_desc_key => "dim_bigidea_bioanimals_desc",
        :text => "Why do animals usually congregate in groups?",
        :desc => "Why do animals usually congregate in groups?",
        :trees => [
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_biocharacteristics",
        :dim_desc_key => "dim_bigidea_biocharacteristics_desc",
        :text => "How are characteristics of one generation passed to the next? Why are individuals of the same species so different?",
        :desc => "How are characteristics of one generation passed to the next? Why are individuals of the same species so different?",
        :trees => [
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_biospecies",
        :dim_desc_key => "dim_bigidea_biospecies_desc",
        :text => "How do we know that different species are related?",
        :desc => "How do we know that different species are related?",
        :trees => [
        ]
      },
      {
        :subject => bio,
        :dim_type => Dimension::BIG_IDEA,
        :dim_name_key => "dim_bigidea_biosurvival",
        :dim_desc_key => "dim_bigidea_biosurvival_desc",
        :text => "Why do some living things survive and reproduce, while others do not?",
        :desc => "Why do some living things survive and reproduce, while others do not?",
        :trees => [
        ]
      }
    ] #dimensions array

    dimensions.each do |dim|
      d = Dimension.create!(
        subject_id: dim[:subject].id,
        dim_type: dim[:dim_type],
        dim_name_key: dim[:dim_name_key],
        dim_desc_key: dim[:dim_desc_key]
      )
      Translation.create!(
        locale: 'en',
        key: dim[:dim_name_key],
        value: dim[:text]
      )
      Translation.create!(
        locale: 'en',
        key: dim[:dim_desc_key],
        value: dim[:desc]
      )
      dim[:trees].each do |t|
        key = "TFV.v01.#{t[:lo].subject.code}.#{t[:lo].code}.bigidea.#{d.id}.expl"
        puts "creating dimension_tree: #{key}"
        DimTree.create!(
          dimension_id: d.id,
          tree_id: t[:lo].id,
          dim_explanation_key: key
        )
        Translation.create!(
          locale:'en',
          key: key,
          value: t[:explanation]
        )
      end #make dimension trees
    end #dimensions.each do |dim|

  end

end




