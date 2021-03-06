class Course < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :participants, through: :registrations, source: :member
  has_many :tickets, dependent: :destroy

  validates :title, presence: true
  validates :registration_start, presence: true
  validates :registration_end, presence: true
  validate :start_is_before_end

  def leads
    registrations.where(role: true)
  end
  def follows
    registrations.where(role: false)
  end

  def register(member, member_params, role, ticket, additional_params)
    ActiveRecord::Base.transaction do
      member.update_attributes(member_params)
      member.save!

      registration = Registration.new(
        member_id: member.id,
        course_id: self.id,
        role: role,
        ticket: ticket,
        status: :triage,
        additional: additional_params
      )
      registration.build_payment(registration: registration)
      registration.save!

      return registration
    end
    return false
  end

  private
  def start_is_before_end
    if self.registration_start > self.registration_end
      errors.add(:registration_start, "cannot be after registration end")
    end
  end

end
