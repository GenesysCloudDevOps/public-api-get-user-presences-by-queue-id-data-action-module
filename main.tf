resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "QueueID" = {
                "description" = "Specify the QueueID (use Get Queue ID by Name action)",
                "type" = "string"
            }
        },
        "required" = [
            "QueueID"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "Available" = {
                "description" = "Number of available agents",
                "type" = "integer"
            },
            "Away" = {
                "description" = "Number of away agents",
                "type" = "integer"
            },
            "Busy" = {
                "description" = "Number of busy agents",
                "type" = "integer"
            },
            "Meal" = {
                "description" = "Number of hungry agents",
                "type" = "integer"
            },
            "Offline" = {
                "description" = "Number of agents not logged in",
                "type" = "integer"
            },
            "OnQueue" = {
                "description" = "Number of on-queue agents",
                "type" = "integer"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\"filter\": \n {\"type\": \"or\", \n \"predicates\": \n [{\"type\": \"dimension\",\n\"dimension\": \"queueId\",\n\"operator\": \"matches\",\n\"value\": \"$${input.QueueID}\"}]},\n\"metrics\": [\"oUserPresences\"]}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/queues/observations/query"
    }

    config_response {
        success_template = "{\"Away\": $${successTemplateUtils.firstFromArray($${Away}, \"0\")}, \"Available\": $${successTemplateUtils.firstFromArray($${Available}, \"0\")}, \"Meal\": $${successTemplateUtils.firstFromArray($${Meal}, \"0\")}, \"OnQueue\": $${successTemplateUtils.firstFromArray($${OnQueue}, \"0\")}, \"Busy\": $${successTemplateUtils.firstFromArray($${Busy}, \"0\")}, \"Offline\": $${successTemplateUtils.firstFromArray($${Offline}, \"0\")}}"
        translation_map = { 
			Away = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == '5e5c5c66-ea97-4e7f-ac41-6424784829f2')].stats.count"
			Busy = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == '31fe3bac-dea6-44b7-bed7-47f91660a1a0')].stats.count"
			Meal = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == '3fd96123-badb-4f69-bc03-1b1ccc6d8014')].stats.count"
			Offline = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == 'ccf3c10a-aa2c-4845-8e8d-f59fa48c58e5')].stats.count"
			Available = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == '6a3af858-942f-489d-9700-5f9bcdcdae9b')].stats.count"
			OnQueue = "$..data[?(@.metric == 'oUserPresences' && @.qualifier == 'e08eaf1b-ee47-4fa9-a231-1200e284798f')].stats.count"
		}
        translation_map_defaults = {       
			Away = "0"
			Busy = "0"
			Meal = "0"
			Offline = "0"
			Available = "0"
			OnQueue = "0"
		}
    }
}