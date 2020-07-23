# README

## Setup Instructions
    > bundle install

### Reset Database
    > bundle exec rake db:reset
    
### Load up Egypt STEM Universities seed data
note: can be rerun (to add new records)
Note: to update existing records, see create_tree_type

    > bundle exec rake seed_eg_stem:populate

### Load up Egypt STEM seed data
note: can be rerun (to add new records)
Note: to update existing records, see create_tree_type

    > bundle exec rake seed_stessa_2:populate
    
### Load up Turkey STEM seed data
    > bundle exec rake seed_turkey_v02:populate
    
### Set the min_grade and max_grade field for Dimensions, Subjects, and Gradebands  
    > bundle exec rake set_min_max_grades:run 

### Run server
Note: Use port 3005 when integrating with SSO in dev
    > bundle exec rails server (-p 3005)

### Upload TFV curriculum data
    - Go to http://localhost:3000 (3005 when integrating with SSO)
    - Sign in as admin@sample.com 
    - Go to http://localhost:3000/en/uploads
    - Click on upload link: 'Upload tfvv02BioAllEng.csv'
    - Click choose file
    - Select and open 'curriculum/config/upload_files/tfvv02BioAllEng.csv'
    - click upload
    - Return to uploads page and repeat the uploads process for all available subjects uploads listed in the uploads table.


## Manually Create a Sector Tree relation(depricated, not needed anymore)
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

