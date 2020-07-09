require 'helpers/test_components_helper'
# require 'test_helper_debugging'
require 'rake'

class DbSeedTest < ActionDispatch::IntegrationTest
  # include Devise::Test::IntegrationHelpers

  setup do
    # load rake tasks for application
    # note: get application name from Rails.application.class.parent_name
    # load "#{Rails.root}/db/seeds.rb"
    Rails.application.load_seed
    Curriculum::Application.load_tasks
    Rake::Task['seed_eg_stem:populate'].invoke
    Rake::Task['seed_turkey_v02:populate'].invoke
    Rake::Task.clear
  end

  test "confirm seed_eg_stem properly loads all tables" do
    assert_equal(2, Version.count)
    assert_equal(2, TreeType.count)
    assert_equal(3, Locale.count)
    @ttTFV = TreeType.where(:code => 'tfv').first
    @ttEgstemUniv = TreeType.where(:code => 'egstemuniv').first
    assert_equal(4, GradeBand.where(:tree_type_id => @ttEgstemUniv.id).count)
    assert_equal(13, GradeBand.where(:tree_type_id => @ttTFV.id).count)
    assert_equal(14, Subject.where(:tree_type_id => @ttTFV.id).count)
    assert_equal(13, Subject.where(:tree_type_id => @ttEgstemUniv.id).count)
    assert_equal(34, Upload.count)
    assert_equal(11, Sector.where(:sector_set_code => 'gr_chall').count)
    assert_equal(8, Sector.where(:sector_set_code => 'future').count)
  end

  test "confirm egstemuniv translations are loaded from seeds" do
    assert_equal('Egypt STEM Teacher Prep Curriculum', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.title', 'xxx'))

    assert_equal('Grade', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.grade', 'xxx'))
    assert_equal('Unit', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.unit', 'xxx'))
    assert_equal('Learning Outcome', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.lo', 'xxx'))

    assert_equal('Grand Challenges', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.set.gr_chall.name', 'xxx'))

    assert_equal('Biology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.bio.name', 'xxx'))
    assert_equal('bio', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.bio.abbr', 'xxx'))
    assert_equal('Capstones', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.cap.name', 'xxx'))
    assert_equal('cap', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.cap.abbr', 'xxx'))

    assert_equal('Chemistry', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.che.name', 'xxx'))
    assert_equal('chem', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.che.abbr', 'xxx'))

    assert_equal('English', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.engl.name', 'xxx'))
    assert_equal('engl', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.engl.abbr', 'xxx'))

    assert_equal('Education', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.edu.name', 'xxx'))
    assert_equal('edu', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.edu.abbr', 'xxx'))

    assert_equal('Geology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.geo.name', 'xxx'))
    assert_equal('geo', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.geo.abbr', 'xxx'))

    assert_equal('Mathematics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mat.name', 'xxx'))
    assert_equal('math', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mat.abbr', 'xxx'))

    assert_equal('Mechanics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mec.name', 'xxx'))
    assert_equal('mec', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.mec.abbr', 'xxx'))

    assert_equal('Physics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.phy.name', 'xxx'))
    assert_equal('phy', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.v01.phy.abbr', 'xxx'))

    assert_equal('Deal with population growth and its consequences.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.1.name', 'xxx'))
    assert_equal('Improve the use of alternative energies.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.2.name', 'xxx'))
    assert_equal('Deal with urban congestion and its consequences.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.3.name', 'xxx'))
    assert_equal('Improve the scientific and technological environment for all.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.4.name', 'xxx'))
    assert_equal('Work to eradicate public health issues/disease.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.5.name', 'xxx'))
    assert_equal('Improve uses of arid areas.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.6.name', 'xxx'))
    assert_equal('Manage and increase the sources of clean water.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.7.name', 'xxx'))
    assert_equal('Increase the industrial and agricultural bases of Egypt.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.8.name', 'xxx'))
    assert_equal('Address and reduce pollution fouling our air, water and soil.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.9.name', 'xxx'))
    assert_equal('Recycle garbage and waste for economic and environmental purposes.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.10.name', 'xxx'))
    assert_equal('Reduce and adapt to the effect of climate change.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.gr_chall.11.name', 'xxx'))

  end

  test "confirm mektebim translations are loaded from seeds" do
    assert_equal('Mektebim STEM Curriculum', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.tfv.title', 'xxx'))

    assert_equal('Grade', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.grade', 'xxx'))
    assert_equal('Unit', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.unit', 'xxx'))
    assert_equal('Sub-Unit', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.subunit', 'xxx'))
    assert_equal('Competence', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.tfv.hierarchy.comp', 'xxx'))

    assert_equal('Future Sectors', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.set.future.name', 'xxx'))

    assert_equal('Biology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.bio.name', 'xxx'))
    assert_equal('bio', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.bio.abbr', 'xxx'))
    assert_equal('Capstones', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.cap.name', 'xxx'))
    assert_equal('cap', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.cap.abbr', 'xxx'))
    assert_equal('Chemistry', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.che.name', 'xxx'))
    assert_equal('chem', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.che.abbr', 'xxx'))
    assert_equal('Education', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.edu.name', 'xxx'))
    assert_equal('edu', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.edu.abbr', 'xxx'))
    assert_equal('English', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.engl.name', 'xxx'))
    assert_equal('engl', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.engl.abbr', 'xxx'))
    assert_equal('Engineering', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.eng.name', 'xxx'))
    assert_equal('eng', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.eng.abbr', 'xxx'))
    assert_equal('Mathematics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.mat.name', 'xxx'))
    assert_equal('math', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.mat.abbr', 'xxx'))
    assert_equal('Mechanics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.mec.name', 'xxx'))
    assert_equal('mec', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.mec.abbr', 'xxx'))
    assert_equal('Physics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.phy.name', 'xxx'))
    assert_equal('phy', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.phy.abbr', 'xxx'))
    assert_equal('Science', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.sci.name', 'xxx'))
    assert_equal('sci', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.sci.abbr', 'xxx'))
    assert_equal('Earth, Space, & Environmental Science', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.ear.name', 'xxx'))
    assert_equal('ear', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.ear.abbr', 'xxx'))
    assert_equal('Geology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.geo.name', 'xxx'))
    assert_equal('geo', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.geo.abbr', 'xxx'))
    assert_equal('Tech Engineering', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.tech.name', 'xxx'))
    assert_equal('tech', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.tfv.v02.tech.abbr', 'xxx'))


    assert_equal('Industry 4.0', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.1.name', 'xxx'))
    assert_equal('Sensors and Imaging Technology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.2.name', 'xxx'))
    assert_equal('New Food Technologies', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.3.name', 'xxx'))
    assert_equal('Biomedical Technology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.4.name', 'xxx'))
    assert_equal('Nanotechnology / Space Technology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.5.name', 'xxx'))
    assert_equal('Global Warming', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.6.name', 'xxx'))
    assert_equal('Internet of Objects / 5G', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.7.name', 'xxx'))
    assert_equal('Population Increase vs Resource Consumption', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.future.8.name', 'xxx'))

  end

end
