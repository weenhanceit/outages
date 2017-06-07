##
# Represents the graph of relationships between CIs
class CisCi < ApplicationRecord
  belongs_to :child, class_name: "Ci"
  belongs_to :parent, class_name: "Ci"
end
