class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  # I18n: локаль з ?locale=uk, інакше типова. Демонструє роботу перекладів.
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.include?(locale.to_sym)
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end
end
