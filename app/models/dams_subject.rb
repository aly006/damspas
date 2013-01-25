class DamsSubject < ActiveFedora::Base
  has_metadata 'damsMetadata', :type => DamsSubjectDatastream 
  delegate_to "damsMetadata", [:label]
end
