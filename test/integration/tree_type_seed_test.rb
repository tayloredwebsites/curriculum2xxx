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
    Rake::Task.clear
  end

  test "confirm seed_eg_stem properly loads all tables" do
    assert_equal(1, Version.count)
    assert_equal(1, TreeType.count)
    assert_equal(3, Locale.count)
    assert_equal(4, GradeBand.count)
    assert_equal(9, Subject.count)
    assert_equal(36, Upload.count)
    assert_equal(11, Sector.count)
  end

  test "confirm translations are loaded from seeds" do
    assert_equal('Egypt STEM Teacher Prep Curriculum', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.title', 'xxx'))

    assert_equal('Grade', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.grade', 'xxx'))
    assert_equal('Unit', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.unit', 'xxx'))
    assert_equal('Learning Outcome', Translation.find_translation_name(BaseRec::LOCALE_EN, 'curriculum.egstemuniv.hierarchy.lo', 'xxx'))

    assert_equal('Grand Challenges', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.set.gr.chal.name', 'xxx'))

    assert_equal('Biology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.bio.name', 'xxx'))
    assert_equal('Bio', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.bio.abbr', 'xxx'))
    assert_equal('Capstones', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.cap.name', 'xxx'))
    assert_equal('Cap', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.cap.abbr', 'xxx'))

    assert_equal('Chemistry', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.che.name', 'xxx'))
    assert_equal('Chem', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.che.abbr', 'xxx'))

    assert_equal('English', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.engl.name', 'xxx'))
    assert_equal('Engl', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.engl.abbr', 'xxx'))

    assert_equal('Education', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.edu.name', 'xxx'))
    assert_equal('Edu', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.edu.abbr', 'xxx'))

    assert_equal('Geology', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.geo.name', 'xxx'))
    assert_equal('Geo', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.geo.abbr', 'xxx'))

    assert_equal('Mathematics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.mat.name', 'xxx'))
    assert_equal('Math', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.mat.abbr', 'xxx'))

    assert_equal('Mechanics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.mec.name', 'xxx'))
    assert_equal('Mec', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.mec.abbr', 'xxx'))

    assert_equal('Physics', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.phy.name', 'xxx'))
    assert_equal('Phy', Translation.find_translation_name(BaseRec::LOCALE_EN, 'subject.egstemuniv.phy.abbr', 'xxx'))

    assert_equal('Deal with population growth and its consequences.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.1.name', 'xxx'))
    assert_equal('Improve the use of alternative energies.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.2.name', 'xxx'))
    assert_equal('Deal with urban congestion and its consequences.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.3.name', 'xxx'))
    assert_equal('Improve the scientific and technological environment for all.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.4.name', 'xxx'))
    assert_equal('Work to eradicate public health issues/disease.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.5.name', 'xxx'))
    assert_equal('Improve uses of arid areas.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.6.name', 'xxx'))
    assert_equal('Manage and increase the sources of clean water.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.7.name', 'xxx'))
    assert_equal('Increase the industrial and agricultural bases of Egypt.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.8.name', 'xxx'))
    assert_equal('Address and reduce pollution fouling our air, water and soil.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.9.name', 'xxx'))
    assert_equal('Recycle garbage and waste for economic and environmental purposes.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.10.name', 'xxx'))
    assert_equal('Reduce and adapt to the effect of climate change.', Translation.find_translation_name(BaseRec::LOCALE_EN, 'sector.egstemuniv.11.name', 'xxx'))

  end

end
