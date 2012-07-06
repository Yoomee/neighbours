FactoryGirl.define do
  
  factory :need do
    user
    description "Take cat to the vet. Put the cat in its box, put it in the car, take it to the vet."
    deadline 1.week.from_now
    association :category, :factory => :need_category
  end
  
  factory :need_category do
    name "Car and Bike"
    description "Car or bike sharing, breakdown, advice, tool sharing, driveway/parking sharing"
  end
  
  factory :offer do
    need
    user
    accepted false
    post_for_need "I can help!"
  end
  
  factory :user do
    first_name "Charlie"
    last_name "Barrett"
    sequence(:email) {|n| "user#{n}@email.com" }
    email_confirmation {email}    
    password "password"
    password_confirmation "password"
    dob 25.years.ago
  end
  
end