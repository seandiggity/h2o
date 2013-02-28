class CreateVersionTables < ActiveRecord::Migration
  def self.up  
    [Case,
     CaseRequest,
     CaseJurisdiction,
     CaseCitation,
     CaseDocketNumber,
     Defect,
     User,
     Annotation,
     Role,
     Collage,
     UserCollection,
     CollageLink,
     Annotation,
     Metadatum,
     Vote,
     ColorMapping,
     UserCollection].each do |klass|
       klass.create_versioned_table
       klass.seed_versioned_data
     end
  end

  def self.down
  end
end