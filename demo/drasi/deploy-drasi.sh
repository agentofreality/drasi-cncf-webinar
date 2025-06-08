#!/bin/bash

# Drasi Deployment Script for CNCF Webinar Demo
# This script deploys the Drasi sources and continuous queries

set -e

echo "Deploying Drasi Sources and Continuous Queries for CNCF Webinar Demo..."

# Function to check if drasi CLI is available
check_drasi_cli() {
    if ! command -v drasi &> /dev/null; then
        echo "Error: drasi CLI is not installed or not in PATH"
        echo "Please install the Drasi CLI first."
        echo "Visit: https://drasi.io/reference/command-line-interface/"
        exit 1
    fi
}

# Function to check if Drasi is installed and running
check_drasi_installation() {
    echo "Checking Drasi installation..."
    if ! drasi list source &> /dev/null; then
        echo "Error: Drasi is not properly installed or not running."
        echo "Please install and start Drasi first."
        echo "Visit: https://drasi.io/docs/getting-started/"
        exit 1
    fi
    echo "Drasi is installed and accessible."
}

# Function to apply sources
deploy_sources() {
    echo "Deploying Drasi Sources..."
    
    echo "  - Applying retail-operations-source..."
    drasi apply -f "$(dirname "$0")/sources/retail-operations-source.yaml"
    
    echo "  - Waiting for retail-operations-source to be ready..."
    drasi wait source retail-operations-source
    
    echo "  - Applying inventory-management-source..."
    drasi apply -f "$(dirname "$0")/sources/inventory-management-source.yaml"
    
    echo "  - Waiting for inventory-management-source to be ready..."
    drasi wait source inventory-management-source
    
    echo "Sources deployed and ready."
}

# Function to apply continuous queries
deploy_queries() {
    echo "Deploying Continuous Queries..."
    
    echo "  - Applying reorder-monitoring-query..."
    drasi apply -f "$(dirname "$0")/queries/reorder-monitoring-query.yaml"
    
    echo "  - Waiting for reorder-monitoring-query to be ready..."
    drasi wait query reorder-monitoring-query
    
    echo "  - Applying supplier-delivery-tracking-query..."
    drasi apply -f "$(dirname "$0")/queries/supplier-delivery-tracking-query.yaml"
    
    echo "  - Waiting for supplier-delivery-tracking-query to be ready..."
    drasi wait query supplier-delivery-tracking-query
    
    echo "Continuous Queries deployed and ready."
}

# Function to apply reactions
deploy_reactions() {
    echo "Deploying Reactions..."
    
    echo "  - Applying reorder-reaction..."
    drasi apply -f "$(dirname "$0")/reactions/reorder-reaction.yaml"
    
    echo "  - Waiting for reorder-reaction to be ready..."
    drasi wait reaction reorder-reaction
    
    echo "Reactions deployed and ready."
}

# Function to verify deployment
verify_deployment() {
    echo "Verifying deployment..."
    
    echo "Sources:"
    drasi list source
    
    echo ""
    echo "Continuous Queries:"
    drasi list query
    
    echo ""
    echo "Reactions:"
    drasi list reaction
    
    echo ""
    echo "Deployment verification completed."
}

# Main execution
main() {
    check_drasi_cli
    check_drasi_installation
    deploy_sources
    deploy_queries
    deploy_reactions
    verify_deployment
    
    echo ""
    echo "🎉 Drasi deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Ensure your PostgreSQL databases are running and accessible"
    echo "2. Insert sample data to trigger the continuous queries"
    echo "3. Monitor query results with: drasi watch reorder-monitoring-query"
    echo ""
    echo "For troubleshooting, check:"
    echo "  drasi describe source retail-operations-source"
    echo "  drasi describe source inventory-management-source"
    echo "  drasi describe query reorder-monitoring-query"
    echo "  drasi describe query supplier-delivery-tracking-query"
    echo "  drasi describe reaction reorder-reaction"
}

main "$@"