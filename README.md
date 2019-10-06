# README



## Manually Create a Sector Tree relation
### till add edit features are written to do this)

    > st = SectorTree.new
    > st.sector_id = 6
    > st.tree_id = 4
    > st.explanation_key = "TFV.v01.bio.9.1.1.1.sector.6.expl"
    > st.save
    > tran = Translation.new
    > tran.locale = 'en'
    > tran.key = "TFV.v01.bio.9.1.1.1.sector.6.expl"
    > tran.value = "Nihil lobortis platonem est ei, ut sit prompta veritus."
    > tran.save

