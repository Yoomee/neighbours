FactoryGirl.define do
  
  factory :need do
    user
    title "Take cat to the vet"
    description "Put the cat in its box, put it in the car, take it to the vet."
    deadline 1.week.from_now
  end
  
  factory :offer do
    need
    user
    text "I'd love to take your cat to the vet. Miaow!"
    accepted false
  end
  
  factory :user do
    first_name "Charlie"
    last_name "Barrett"
    sequence(:email) {|n| "charlie#{n}@yoomee.com" }
    password "password"
  end
  
end