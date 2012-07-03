class Tag < ActsAsTaggableOn::Tag
  include YmTags::Tag
end
Tag::CATEGORY_OPTIONS = [
                         ["Car or bike", "car-or-bike"],
                         ["House", "house"],
                         ["Shopping", "shopping"],
                         ["Pets", "pet"],
                         ["Garden", "garden"],
                         ["Child", "child"],
                         ["Nature", "nature"],
                         ["Social", "social"],
                         ["Cleaning", "cleaning"],
                         ["Disability Assistance", "disability-assistance"],
                         ["Swap", "swap"],
                         ["Community", "community"],
                         ["Societies", "societies"],
                         ["Health", "health"],
                         ["Other", "other"]
                        ] 