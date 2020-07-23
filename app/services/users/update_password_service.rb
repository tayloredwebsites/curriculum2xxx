module Users
  class UpdatePasswordService
    def self.perform(user, params)
      obj = new(user, params)
      obj.run
    end

    def initialize(user, params)
      @user = user
      @params = params
    end

    def run
      if @user.update_attributes(@params)
        true
      else
        false
      end
    end

  end
end
