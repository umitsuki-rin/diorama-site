class ContactsController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { render_limited }

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      render :create
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def contact_params
      params.expect(contact: %i[ company_name name email body ])
    end

    def render_limited
      @contact = Contact.new
      @contact.errors.add(:base, "送信回数が上限に達しました。しばらくしてから再度お試しください。")
      render :new, status: :too_many_requests
    end
end
