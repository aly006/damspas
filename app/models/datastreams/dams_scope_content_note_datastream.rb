class DamsScopeContentNoteDatastream < DamsDatastream
  map_predicates do |map|    
    map.value(:in=> RDF)
    map.displayLabel(:in=>DAMS)
    map.type(:in=>DAMS)
  end

  rdf_subject { |ds| RDF::URI.new(Rails.configuration.id_namespace + ds.pid)}
  def serialize
    graph.insert([rdf_subject, RDF.type, DAMS.ScopeContentNote]) if new?
    super
  end
  
  def to_solr (solr_doc = {})           
    Solrizer.insert_field(solr_doc, 'scopeContentNote_value', value)
	Solrizer.insert_field(solr_doc, 'scopeContentNote_displayLabel', displayLabel)
	Solrizer.insert_field(solr_doc, 'scopeContentNote_type', type) 			
	super
    return solr_doc
  end
  
end
