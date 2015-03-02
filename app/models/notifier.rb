class Notifier < ActionMailer::Base

def reset_password user, new_pass
  setup_email user
  subject "Nueva contraseña Intranet mvconsultoria"
  content_type "text/html"
  body :new_pass => new_pass 
end

def offer_win_notification user, offer

    setup_email user
    subject "Propuesta #{offer.actual_version.version_cod} ganada"
    content_type "text/html"
    body :offer => offer, :user => user
    
end

def responsable_notification user, offer

    setup_email user
    subject "La propuesta #{offer.actual_version.version_cod} le ha sido asignada"
    content_type "text/html"
    body :offer => offer

end

protected
    def setup_email user
      if not Rails.env.production? || Rails.env.test?
        tag = user.email.split("@")[0]
        recipients "david.garcia+#{tag}@mvconsultoria.com"
      else
        recipients "#{user.email}"
      end
      from "Intranet Mvconsultoria"
    end
end
