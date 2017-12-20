FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-email#{n}@sample.com" }
    sequence(:password) { |n| "user-password#{n}" }
    sequence(:given_name) { |n| "given-name#{n}"}
    sequence(:family_name) { |n| "family-name#{n}"}
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
    tree_type_id 1
    version_id 1
    subject
    grade_band
  end
end
