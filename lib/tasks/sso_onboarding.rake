namespace :sso_onboarding do

  desc 'Find a teacher from Tracker and create that teacher in curriculum'
  
  task create_demo_user: :environment do

    user = User.create!(
      given_name: '21pstem',
      family_name: 'teacher',
      email: 'demo_teacher@21pstem.org',
      password: 'Simple123!',
      password_confirmation: 'Simple123!',
      municipality: 'nyc',
      roles: 'public',
      govt_level: "1",
      institute_type: "4",
      gender: '0',
      position_type: "7",
      terms_accepted: true,
      work_address: "work_address",
      education_level: "0"
    )

    user.confirmed_at = Time.now
    user.save
  end

end