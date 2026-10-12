class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: %i[ show update destroy ]

  def index
    @contacts = Contact.latest_first
  end

  def show
  end

  # 対応済み／未対応の切り替え
  def update
    @contact.update!(responded: !@contact.responded)
    redirect_back_or_to admin_contact_path(@contact), notice: @contact.responded ? "対応済みにしました。" : "未対応に戻しました。"
  end

  def destroy
    @contact.destroy!
    redirect_to admin_contacts_path, notice: "お問い合わせを削除しました。", status: :see_other
  end

  private
    def set_contact
      @contact = Contact.find(params[:id])
    end
end
