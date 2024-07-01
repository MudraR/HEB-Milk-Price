# HEB's graphql endpiont
$uri = "https://api-edge.heb-ecom-api.hebdigital-prd.com/graphql"

# Define the variables for the GraphQL query
$variables = @{
    categoryId = "490053" # Category ID for milk
    storeId = 615 # Store ID
    limit = 5 # limiting to 5 records since I just want the popular ones to gauge the price
}

# GraphQL query to get the price of a product.  
$query = @"
query Query(`$categoryId: String!, `$storeId: Int!, `$limit: Int!) {
    browseCategory(
        categoryId: `$categoryId
        storeId: `$storeId
        shoppingContext: CURBSIDE_PICKUP
        limit: `$limit
    ) {
        pageTitle
        records {
            id
            displayName
            brand {
                name
                isOwnBrand
            }
            SKUs {
                id
                contextPrices {
                    context
                    isOnSale
                    unitListPrice {
                        unit
                        formattedAmount
                    }
                    priceType
                    listPrice {
                        unit
                        formattedAmount
                    }
                    salePrice {
                        formattedAmount
                    }
                }
            }
        }
        total
        hasMoreRecords
        nextCursor
        previousCursor
    }
}
"@

# combine the query and variables into a JSON object for the body of the POST request
$body = @{
    query = $query
    variables = $variables
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"

# Get the milk records.
$milkRecords = $response.data.browseCategory.records

foreach ($record in $milkRecords) {
    Write-Host "Display Name: $($record.displayName)"
    foreach ($sku in $record.SKUs) {
        foreach ($contextPrice in $sku.contextPrices) {
            Write-Host "Context: $($contextPrice.context)"
            Write-Host "List Price: $($contextPrice.listPrice.formattedAmount)"
        }
    }
    Write-Host "----------------------------------------"
}
