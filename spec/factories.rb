FactoryGirl.define do
  
  factory :need do |need|
    need.user
    need.title "Take cat to the vet"
    need.description "Put the cat in its box, put it in the car, take it to the vet."
    need.deadline 1.week.from_now
  end
  
  factory :offer do |offer|
    offer.need
    offer.user
    offer.text "I'd love to take your cat to the vet. Miaow!"
    offer.accepted false
  end
  
  factory :user do |user|
    user.first_name "Charlie"
    user.last_name "Barrett"
    user.email {"user_#{rand(1000).to_s}@factory.com" }
    user.password "password"
  end
  
end