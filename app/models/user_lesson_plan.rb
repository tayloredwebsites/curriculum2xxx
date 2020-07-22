class UserLessonPlan < BaseRec
  belongs_to :lesson_plan
  belongs_to :user

  def self.build_header_table(users)
   user_full_names = users.map { |u| u.full_name }.join(', ')
   return {
      table_partial_name: 'trees/show/simple_header',
      headers_array: [{text: "<strong>#{I18n.t('lesson_plan.authors')}:</strong> #{user_full_names}" }],
      content_array: [{}]
    }
  end

end