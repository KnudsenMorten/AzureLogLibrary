{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "dataCollectionRuleName": {
            "type": "string",
            "metadata": {
                "description": "Data Collection Rule Name"
            }
        },
        "location": {
            "type": "string",
            "metadata": {
                "description": "Data Collection Rule Location"
            }
        },
        "workspaceName": {
            "type": "string",
            "metadata": {
                "description": "LogAnalytics Workspace Name"
            }
        },
        "workspaceResourceId": {
            "type": "string",
            "metadata": {
                "description": "LogAnalytics Workspace Resource ID"
            }
        },
        "endpointResourceId": {
            "type": "string",
            "metadata": {
                "description": "Data COllection Endpoint Resource ID"
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Insights/dataCollectionRules",
            "name": "[parameters('dataCollectionRuleName')]",
            "location": "[parameters('location')]",
            "apiVersion": "2021-09-01-preview",
            "properties": {
                "dataCollectionEndpointId": "[parameters('endpointResourceId')]",
                "streamDeclarations": {
                    "Custom-MyLogFileFormat": {
                        "columns": [
                            {
                                "name": "TimeGenerated",
                                "type": "datetime"
                            },
                            {
                                "name": "RawData",
                                "type": "string"
                            }
                        ]
                    }
                },
                "dataSources": {
                    "logFiles": [
                        {
                            "streams": [
                                "Custom-MyLogFileFormat"
                            ],
                            "filePatterns": [
                                "C:\\JavaLogs\\*.log"
                            ],
                            "format": "text",
                            "settings": {
                                "text": {
                                    "recordStartTimestampFormat": "ISO 8601"
                                }
                            },
                            "name": "myLogFileFormat-Windows"
                        },
                        {
                            "streams": [
                                "Custom-MyLogFileFormat" 
                            ],
                            "filePatterns": [
                                "//var//*.log"
                            ],
                            "format": "text",
                            "settings": {
                                "text": {
                                    "recordStartTimestampFormat": "ISO 8601"
                                }
                            },
                            "name": "myLogFileFormat-Linux"
                        }
                    ]
                },
                "destinations": {
                    "logAnalytics": [
                        {
                            "workspaceResourceId": "[parameters('workspaceResourceId')]",
                            "name": "[parameters('workspaceName')]"
                        }
                    ]
                },
                "dataFlows": [
                    {
                        "streams": [
                            "Custom-MyLogFileFormat"
                        ],
                        "destinations": [
                            "[parameters('workspaceName')]"
                        ],
                        "transformKql": "source",
                        "outputStream": "Custom-MyTable_CL"
                    }
                ]
            }
        }
    ],
    "outputs": {
        "dataCollectionRuleId": {
            "type": "string",
            "value": "[resourceId('Microsoft.Insights/dataCollectionRules', parameters('dataCollectionRuleName'))]"
        }
    }
}