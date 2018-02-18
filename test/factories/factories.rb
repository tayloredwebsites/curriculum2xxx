FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-email#{n}@sample.com" }
    sequence(:password) { |n| "user-password#{n}" }
    sequence(:given_name) { |n| "given-name#{n}"}
    sequence(:family_name) { |n| "family-name#{n}"}
    sequence(:govt_level) { |n| "govt_level#{n}" }
    sequence(:govt_level_name) { |n| "govt_level_name#{n}" }
    sequence(:municipality) { |n| "municipality#{n}" }
    sequence(:institute_type) { |n| "institute_type#{n}" }
    sequence(:institute_name_loc) { |n| "institute_name_loc#{n}" }
    sequence(:position_type) { |n| "position_type#{n}" }
    sequence(:subject1) { |n| "subject1#{n}" }
    sequence(:subject2) { |n| "subject2#{n}" }
    sequence(:gender) { |n| "gender#{n}" }
    sequence(:education_level) { |n| "education_level#{n}" }
    sequence(:work_phone) { |n| "work_phone#{n}" }
    sequence(:work_address) { |n| "work_address#{n}" }
    sequence(:terms_accepted) { |n| "terms_accepted#{n}" }
  end

  # factory :tree_type do
  #   code "OTC"
  # end

  # factory :version do
  #   code "v01"
  # end

  factory :subject do
    sequence(:code) { |n| "subject-code#{n}"}
  end

  factory :grade_band do
    sequence(:code) { |n| "grade-band-code#{n}"}
  end

  factory :tree do
    tree_type_id BaseRec::TREE_TYPE_ID
    version_id BaseRec::VERSION_ID
    subject
    grade_band
  end

  factory :upload do
    subject
    grade_band
    trait :english do
      locale 'en'
    end
    status BaseRec::UPLOAD_NOT_UPLOADED
  end

end
