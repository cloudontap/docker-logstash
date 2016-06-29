{
	"template": "logs-*",
	"order": 1,
	"settings": {
		"number_of_shards": ${SHARDS},
		"number_of_replicas": ${REPLICAS},
		"index.refresh_interval": "5s"
	},
	"mappings": {
		"_default_": {
			"include_in_all": false,
			"_all": {
				"enabled": false,
				"analyzer": "whitespace"
			},
			"_source": {
				"enabled": true
			},
			"dynamic": "true",
			"date_detection": true,
			"dynamic_templates": [
				{
					"boolean_fields": {
						"match": "*",
						"match_mapping_type": "boolean",
						"mapping": {
							"type": "boolean",
							"doc_values": true
						}
					}
				}, {
					"string_fields": {
						"match": "*",
						"match_mapping_type": "string",
						"mapping": {
							"type": "string",
							"index": "not_analyzed",
							"doc_values": true
						}
					}
				}, {
					"float_fields": {
						"match": "*",
						"match_mapping_type": "float",
						"mapping": {
							"type": "float",
							"doc_values": true
						}
					}
				}, {
					"double_fields": {
						"match": "*",
						"match_mapping_type": "double",
						"mapping": {
							"type": "double",
							"doc_values": true
						}
					}
				}, {
					"byte_fields": {
						"match": "*",
						"match_mapping_type": "byte",
						"mapping": {
							"type": "byte",
							"doc_values": true
						}
					}
				}, {
					"short_fields": {
						"match": "*",
						"match_mapping_type": "short",
						"mapping": {
							"type": "short",
							"doc_values": true
						}
					}
				}, {
					"integer_fields": {
						"match": "*",
						"match_mapping_type": "integer",
						"mapping": {
							"type": "integer",
							"doc_values": true
						}
					}
				}, {
					"long_fields": {
						"match": "*",
						"match_mapping_type": "long",
						"mapping": {
							"type": "long",
							"doc_values": true
						}
					}
				}, {
					"date_fields": {
						"match": "*",
						"match_mapping_type": "date",
						"mapping": {
							"type": "date",
							"doc_values": true
						}
					}
				}, {
					"geo_point_fields": {
						"match": "*",
						"match_mapping_type": "geo_point",
						"mapping": {
							"type": "geo_point",
							"doc_values": true
						}
					}
				}
			],
			"properties": {
				"@timestamp": {
					"type": "date",
					"doc_values": true,
					"format": "dateOptionalTime"
				},
				"@version": {
					"type": "string",
					"index": "not_analyzed",
					"doc_values": true
				},
				"message": {
					"type": "string",
					"index": "analyzed",
					"omit_norms": true,
					"fielddata": {
						"format": "disabled"
					}
				},
				"type": {
					"type": "string",
					"index": "not_analyzed",
					"doc_values": true
				},
				"useragent": {
					"type": "object",
					"dynamic": true,
					"properties": {
					    "raw" : {
					        "type": "string",
					        "index": "analyzed",
					        "omit_norms": true,
					        "fielddata": {
					            "format": "disabled"
					        }
					    }
					}
				},
				"geoip": {
					"type": "object",
					"dynamic": true,
					"properties": {
						"ip": {
							"type": "ip",
							"doc_values": true
						},
						"location": {
							"type": "geo_point",
							"doc_values": true
						},
						"latitude": {
							"type": "float",
							"doc_values": true
						},
						"longitude": {
							"type": "float",
							"doc_values": true
						}
					}
				}
			}
		}
	}
}