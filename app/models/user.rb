class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :rememberable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :registerable, :timeoutable, :trackable, :validatable
end
