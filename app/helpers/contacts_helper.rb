module ContactsHelper
  def spam_form_token
    SpamProtection.form_token
  end
end
