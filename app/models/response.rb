class Response < ActiveRecord::Base

    # ASSOCIATIONS

    belongs_to :question
    belongs_to :user

    # VALIDATIONS

    validates :text, presence: {message: "A response has not been entered."}

end
