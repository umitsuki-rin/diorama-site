module AdminHelper
  INPUT_CLASS = "w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none".freeze
  FILE_INPUT_CLASS = "block w-full text-sm text-gray-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100".freeze
  PRIMARY_BUTTON_CLASS = "px-6 py-2.5 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 cursor-pointer".freeze
  SECONDARY_BUTTON_CLASS = "px-6 py-2.5 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 cursor-pointer".freeze

  ADMIN_MENU = [
    { label: "ダッシュボード", icon: "fa-gauge", path: :admin_root_path, controller: "admin/dashboard" },
    { label: "サイト設定", icon: "fa-gear", path: :admin_site_setting_path, controller: "admin/site_settings" },
    { label: "楽曲", icon: "fa-music", path: :admin_songs_path, controller: "admin/songs" },
    { label: "プロフィール", icon: "fa-user", path: :admin_profile_path, controller: "admin/profiles" },
    { label: "ニュース", icon: "fa-newspaper", path: :admin_news_index_path, controller: "admin/news" },
    { label: "お問い合わせ", icon: "fa-envelope", path: :admin_contacts_path, controller: "admin/contacts" },
    { label: "ユーザー管理", icon: "fa-users", path: :admin_users_path, controller: "admin/users", developer_only: true }
  ].freeze

  # ログイン中のユーザーに表示するメニュー（ユーザー管理は開発者だけ）
  def admin_menu_items
    ADMIN_MENU.reject { it[:developer_only] && !Current.user&.developer? }
  end

  def admin_menu_item_class(item)
    base = "flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium"
    if controller_path == item[:controller]
      "#{base} bg-indigo-50 text-indigo-700"
    else
      "#{base} text-gray-600 hover:bg-gray-100 hover:text-gray-900"
    end
  end

  def status_badge(record)
    classes = record.published? ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-600"
    tag.span(record.status_label, class: "px-2 py-0.5 rounded text-xs #{classes}")
  end

  def responded_badge(contact)
    if contact.responded?
      tag.span("対応済み", class: "px-2 py-0.5 rounded text-xs bg-green-100 text-green-700")
    else
      tag.span("未対応", class: "px-2 py-0.5 rounded text-xs bg-amber-100 text-amber-700")
    end
  end

  def admin_label(form, attribute, required: false, note: nil)
    form.label(attribute, class: "block text-sm font-medium text-gray-700 mb-1") do
      safe_join([ form.object.class.human_attribute_name(attribute), (" *" if required), (tag.span(" #{note}", class: "text-xs text-gray-400") if note) ].compact)
    end
  end
end
