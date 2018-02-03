class ApiController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  before_action :disable_cors
  before_action :set_default_response_format

  def courses
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      @courses = Course.all
      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def course
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      @course = Course.find(params[:id])
      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def register
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      @member = Member.find_or_initialize_by(email: params[:email])
      @course = Course.find(params[:course])
      @ticket = @course.tickets.find(params[:ticket])
      role = params[:role]
      additional_params = params[:additional]

      if Registration.exists?(member_id: @member.id, course_id: @course.id)
        @registration = Registration.where(member_id: @member.id, course_id: @course.id).first
        render :register, status: :conflict
        return
      end

      begin
        @registration = @course.register(@member, member_params, role, @ticket, additional_params)
        payment = @registration.payment
        render :register, status: :created
      rescue Exception => e
        render json: { error: 0, message: e.message}, status: :unprocessable_entity
      end

    ensure
      Apartment::Tenant.reset
    end

  end

  def payments_webhook

    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      payment = Payment.where(remote_id: params[:id]).first
      if payment == nil
        raise ActiveRecord::RecordNotFound
      end

      mollie = Mollie::API::Client.new(Setting.mollie_api_key)
      mollie_payment = mollie.payments.get payment.remote_id

      if mollie_payment.paid?
          payment.status = :paid
      elsif !mollie_payment.open?
          payment.status = :aborted
      end
      payment.save!
    rescue Mollie::API::Exception => e
        render text: "Failed", status: 500
    ensure
      Apartment::Tenant.reset
    end

  end

  def payment_status
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      @payment = Payment.find(params[:id])
    ensure
      Apartment::Tenant.reset
    end
  end

  private
  def set_default_response_format
    request.format = :json
  end

  def registration_params
    params.require(:registration).permit(:status)
  end

  def member_params
    params.permit(:firstname, :lastname, :email, :address)
  end

  def course_params
    params.permit(:course_id)
  end

  def disable_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  # def cors_set_access_control_headers
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #   headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  # end
  #
  # def cors_preflight_check
  #   if request.method == 'OPTIONS'
  #     headers['Access-Control-Allow-Origin'] = '*'
  #     headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #     headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
  #
  #     render :text => '', :content_type => 'text/plain'
  #   end
  # end

end