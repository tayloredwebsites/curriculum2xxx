class User < BaseRec
  # Include default devise modules. Others available are:
  # :rememberable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :registerable, :timeoutable, :trackable, :validatable

  validates :given_name, presence: true
  validates :family_name, presence: true


  ADMIN_ROLE = 'admin'
  TEACHER_ROLE = 'teacher'
  REQ_TEACHER_ROLE = 'req_teacher'
  VALID_ROLES = ["#{ADMIN_ROLE}", "#{TEACHER_ROLE}", "#{REQ_TEACHER_ROLE}"]
  ROLE_ABBREVS = [
    I18n.translate('app.roles.admin.abbrev'),
    I18n.translate('app.roles.teacher.abbrev'),
    I18n.translate('app.roles.req_teacher.abbrev')
  ]
  ROLE_NAMES = [
    I18n.translate('app.roles.admin.name'),
    I18n.translate('app.roles.teacher.name'),
    I18n.translate('app.roles.req_teacher.name')
  ]
  ROLES_ADMIN = 0
  ROLES_TEACHER = 1
  ROLES_REQ = 2

  IS_CHECKED_VALUES = ['true', 'on', '1']

  scope :requesting_teachers, -> {
    where(roles: "#{REQ_TEACHER_ROLE}")
  }

  scope :all_unregistered, -> {
    where("roles = ? OR roles = ?", '', REQ_TEACHER_ROLE)
  }

  def role_names
    ret = []
    roles_array = get_roles_array
    ret << ROLE_NAMES[ROLES_ADMIN] if roles_array.include?(ADMIN_ROLE)
    ret << ROLE_NAMES[ROLES_TEACHER] if roles_array.include?(TEACHER_ROLE)
    # ret << ROLE_NAMES[ROLES_REQ] if roles_array.include?(REQ_TEACHER_ROLE)
    return ret.join(', ')
  end

  def role_abbrevs
    ret = []
    roles_array = get_roles_array
    ret << ROLE_ABBREVS[ROLES_ADMIN] if roles_array.include?(ADMIN_ROLE)
    ret << ROLE_ABBREVS[ROLES_TEACHER] if roles_array.include?(ROLES_TEACHER)
    # ret << ROLE_ABBREVS[ROLES_REQ] if roles_array.include?(ROLES_REQ)
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

  def role_req_teacher=(val)
    roles_array = get_roles_array
    if IS_CHECKED_VALUES.include?(val) && !roles_array.include?(REQ_TEACHER_ROLE)
      roles_array << REQ_TEACHER_ROLE if !roles_array.include?(REQ_TEACHER_ROLE)
    elsif !IS_CHECKED_VALUES.include?(val) && roles_array.include?(REQ_TEACHER_ROLE)
      roles_array = roles_array - ["#{REQ_TEACHER_ROLE}"]
    end
    self.roles = roles_array.join(',')
  end
  def role_req_teacher
    roles_array = get_roles_array
    return roles_array.include?(REQ_TEACHER_ROLE)
  end
  def is_req_teacher?
    roles_array = get_roles_array
    return roles_array.include?(REQ_TEACHER_ROLE)
  end

  def is_registered?
    roles_array = get_roles_array
    return roles_array.include?(TEACHER_ROLE) || roles_array.include?(ADMIN_ROLE)
  end

  def is_requesting_teacher_role?
    roles_array = get_roles_array
    return roles_array.include?(REQ_TEACHER_ROLE)
  end

  def is_registering?
    return !is_registered?
  end

  def full_name
    return "#{self.given_name} #{self.family_name}"
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
