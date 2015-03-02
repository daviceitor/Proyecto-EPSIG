
Factory.define :account do |a|
  a.name {Faker::Company.name}
  a.description {Faker::Company.bs}
  a.account_type {Account.account_types[rand(Account.account_types.length)]}
  a.industry_type {Account.industry_types[rand(Account.industry_types.length)]}
  a.website {Faker::Internet.domain_name}
end

Factory.define :seat do |s|
  s.name {Faker::Address.city}
  s.street {Faker::Address.street_name}
  s.city {Faker::Address.city}
  s.state {Faker::Address.us_state}
  s.postalcode {Faker::Address.zip_code}
  s.country {Faker::Address.uk_country}
  s.contact_means{{"Teléfono Oficina" => Faker::PhoneNumber.phone_number}}
  s.association :account, :factory => :account
end

Factory.define :contact do |c|
  c.name {Faker::Name.first_name}
  c.sur_name {Faker::Name.last_name}
  c.description {Faker::Company.catch_phrase}
  c.lead_source {Contact.lead_sources[rand(Contact.lead_sources.length)]}
  c.title {Faker::Company.catch_phrase}
  c.department {Faker::Company.bs}
  c.contact_means{{"Email" => Faker::Internet.email(Faker::Name.name), "Teléfono" => Faker::PhoneNumber.phone_number}}
  c.association :seat, :factory => :seat
end

Factory.define :resource do |r|
  r.name {Faker::Company.bs}
  r.url {Faker::Internet.domain_name}
  r.association :user, :factory => :user
end

Factory.define :offer_type do |ot|
  ot.object_id {rand(OfferType.offer_types.length)}
  ot.name {OfferType.offer_types[rand(OfferType.offer_types.length)]}
end

Factory.define :user do |u|
  pass = "fucker"
  u.name {Faker::Name.name}
  u.password {pass}
  u.password_confirmation {pass}
  u.email {Faker::Internet.email(Faker::Name.first_name)}
end

Factory.define :version do |v|
  v.cod {1}
  v.description {Faker::Company.bs}
  v.licences_amount {rand(10000)}
  v.recurrent_services_amount {rand(8000)}
  v.no_recurrent_services_amount {rand(5000)}
  v.doc_file_name {"#{Faker::Company.name}_propuesta_XX_#{rand(500)+1500}.doc"}
  v.association :offer, :factory => :offer
end

Factory.define :offer do |o|
  o.approved_doc_file_name {"#{rand(500)+1500}_doc_aprobacion.doc"}
  o.win_probability {rand(101)}
  o.estimated_date_resolution {Date.today-rand(1000).days}
  o.order_cod {Faker::PhoneNumber.phone_number}
  o.actual_version_index {0}
  o.association :account, :factory => :account
  o.association :intermediary, :factory => :account
  o.association :offer_type, :factory => :offer_type
  o.association :commercial, :factory => :user
  o.association :responsable, :factory => :user
end

Factory.define :bill do |b|
  b.association :offer, :factory => :offer
end