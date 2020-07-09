class User < BaseRec
  # Include default devise modules. Others available are:
  # :rememberable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :registerable, :timeoutable, :trackable, :validatable

  validates :given_name, presence: true
  validates :family_name, presence: true
  # validates :govt_level, presence: true
  # validates :govt_level_name, presence: true
  validates :municipality, presence: true
  validates :institute_type, presence: true
  #validates :institute_name_loc, presence: true
  validates :position_type, presence: true
  # validates :subject1, presence: true
  # validates :subject2, presence: true
  validates :gender, presence: true
  validates :education_level, presence: true
  validates :work_address, presence: true
  validates :terms_accepted, presence: true

  has_many :user_resources
  has_many :resources, through: :user_resources

  has_many :user_lesson_plans
  has_many :lesson_plans, through: :user_lesson_plans

  before_create :set_default_role

  ADMIN_ROLE = 'admin'
  TEACHER_ROLE = 'teacher'
  PUBLIC_ROLE = 'public'
  COUNSELOR_ROLE = 'counselor'
  SUPERVISOR_ROLE = 'supervisor'
  VALID_ROLES = ["#{ADMIN_ROLE}", "#{TEACHER_ROLE}", "#{PUBLIC_ROLE}", "#{COUNSELOR_ROLE}", "#{SUPERVISOR_ROLE}"]
  ROLE_ABBREVS = [
    I18n.translate('app.roles.admin.abbrev'),
    I18n.translate('app.roles.teacher.abbrev'),
    I18n.translate('app.roles.public.abbrev'),
    I18n.translate('app.roles.counselor.name'),
    I18n.translate('app.roles.supervisor.name'),
  ]
  ROLE_NAMES = [
    I18n.translate('app.roles.admin.name'),
    I18n.translate('app.roles.teacher.name'),
    I18n.translate('app.roles.public.name'),
    I18n.translate('app.roles.counselor.name'),
    I18n.translate('app.roles.supervisor.name'),
  ]
  ROLES_ADMIN = 0
  ROLES_TEACHER = 1
  ROLES_PUBLIC = 2
  ROLES_COUNSELOR = 3
  ROLES_SUPERVISOR = 4

  GOVT_LEVELS = [
    I18n.translate('activerecord.attributes.user.govt_level_val0'),
    I18n.translate('activerecord.attributes.user.govt_level_val1'),
    I18n.translate('activerecord.attributes.user.govt_level_val2'),
    I18n.translate('activerecord.attributes.user.govt_level_val3'),
    I18n.translate('activerecord.attributes.user.govt_level_val4'),
    I18n.translate('activerecord.attributes.user.govt_level_val5')
  ]
  INSTITUTE_TYPE = [
    I18n.translate('activerecord.attributes.user.institute_type_val0'),
    I18n.translate('activerecord.attributes.user.institute_type_val1'),
    I18n.translate('activerecord.attributes.user.institute_type_val2'),
    I18n.translate('activerecord.attributes.user.institute_type_val3'),
    I18n.translate('activerecord.attributes.user.institute_type_val4'),
    I18n.translate('activerecord.attributes.user.institute_type_val5'),
    I18n.translate('activerecord.attributes.user.institute_type_val6')
  ]
  POSITION_TYPE = [
    I18n.translate('activerecord.attributes.user.position_type_val0'),
    I18n.translate('activerecord.attributes.user.position_type_val1'),
    I18n.translate('activerecord.attributes.user.position_type_val2'),
    I18n.translate('activerecord.attributes.user.position_type_val3'),
    I18n.translate('activerecord.attributes.user.position_type_val4'),
    I18n.translate('activerecord.attributes.user.position_type_val5'),
    I18n.translate('activerecord.attributes.user.position_type_val6'),
    I18n.translate('activerecord.attributes.user.position_type_val7')
  ]
  GENDER = [
    I18n.translate('activerecord.attributes.user.gender_val0'),
    I18n.translate('activerecord.attributes.user.gender_val1')
  ]
  EDUCATION_LEVEL = [
    I18n.translate('activerecord.attributes.user.education_level_val0'),
    I18n.translate('activerecord.attributes.user.education_level_val1'),
    I18n.translate('activerecord.attributes.user.education_level_val2')
  ]

  IS_CHECKED_VALUES = ['true', 'on', '1']


  scope :all_unregistered, -> {
    where("roles = ''")
  }

  scope :active, -> {
    where(:active => true)
  }

  def set_default_role
    if self.roles == '' && TreeType.where(:code => 'tfv').count > 0
      self.roles = PUBLIC_ROLE
    end
  end

  def active_for_authentication?
    super && active && roles.length > 0
  end

  def role_names
    ret = []
    roles_array = get_roles_array
    ret << ROLE_NAMES[ROLES_ADMIN] if roles_array.include?(ADMIN_ROLE)
    ret << ROLE_NAMES[ROLES_TEACHER] if roles_array.include?(TEACHER_ROLE)
    ret << ROLE_NAMES[ROLES_PUBLIC] if roles_array.include?(PUBLIC_ROLE)
    ret << ROLE_NAMES[ROLES_COUNSELOR] if roles_array.include?(COUNSELOR_ROLE)
    ret << ROLE_NAMES[ROLES_SUPERVISOR] if roles_array.include?(SUPERVISOR_ROLE)
    return ret.join(', ')
  end

  def role_admin=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(ADMIN_ROLE)
      roles_array << ADMIN_ROLE if !roles_array.include?(ADMIN_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(ADMIN_ROLE)
      roles_array = roles_array - ["#{ADMIN_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_admin
    roles_array = get_roles_array
    return roles_array.include?(ADMIN_ROLE)
  end
  def is_admin?
    roles_array = get_roles_array
    return roles_array.include?(ADMIN_ROLE)
  end

  def role_teacher=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(TEACHER_ROLE)
      roles_array << TEACHER_ROLE if !roles_array.include?(TEACHER_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(TEACHER_ROLE)
      roles_array = roles_array - ["#{TEACHER_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_teacher
    roles_array = get_roles_array
    return roles_array.include?(TEACHER_ROLE)
  end
  def is_teacher?
    roles_array = get_roles_array
    return roles_array.include?(TEACHER_ROLE)
  end

  def role_public=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(PUBLIC_ROLE)
      roles_array << PUBLIC_ROLE if !roles_array.include?(PUBLIC_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(PUBLIC_ROLE)
      roles_array = roles_array - ["#{PUBLIC_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_public
    roles_array = get_roles_array
    return roles_array.include?(PUBLIC_ROLE)
  end
  def is_public?
    roles_array = get_roles_array
    return roles_array.include?(PUBLIC_ROLE)
  end

    def role_counselor=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(COUNSELOR_ROLE)
      roles_array << COUNSELOR_ROLE if !roles_array.include?(COUNSELOR_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(COUNSELOR_ROLE)
      roles_array = roles_array - ["#{COUNSELOR_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_counselor
    roles_array = get_roles_array
    return roles_array.include?(COUNSELOR_ROLE)
  end
  def is_counselor?
    roles_array = get_roles_array
    return roles_array.include?(COUNSELOR_ROLE)
  end

  def role_supervisor=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(SUPERVISOR_ROLE)
      roles_array << SUPERVISOR_ROLE if !roles_array.include?(SUPERVISOR_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(SUPERVISOR_ROLE)
      roles_array = roles_array - ["#{SUPERVISOR_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_supervisor
    roles_array = get_roles_array
    return roles_array.include?(SUPERVISOR_ROLE)
  end
  def is_supervisor?
    roles_array = get_roles_array
    return roles_array.include?(SUPERVISOR_ROLE)
  end

  def is_registered?
    if is_admin? || is_teacher? || is_counselor? || is_supervisor? || is_public?
      return true
    end
  end
  def is_registering?
    return !is_registered?
  end

  def full_name
    return "#{self.given_name} #{self.family_name}"
  end

  def subject_admin?(subject_code)
    return admin_subjects.split(',').include?(subject_code)
  end

  private

  def get_roles_array
    if self.roles.present?
      return self.roles.split(',')
    else
      return []
    end
  end


end
