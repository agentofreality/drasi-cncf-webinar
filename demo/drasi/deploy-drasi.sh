#!/bin/bash

# Drasi Deployment Script for CNCF Webinar Demo
# This script deploys the Drasi sources and continuous queries

set -e

echo "Deploying Drasi Sources and Continuous Queries for CNCF Webinar Demo..."

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if Drasi CRDs are installed
check_drasi_crds() {
    echo "Checking for Drasi CRDs..."
    if ! kubectl get crd sources.drasi.io &> /dev/null; then
        echo "Error: Drasi CRDs not found. Please install Drasi first."
        echo "Visit: https://drasi.io/docs/getting-started/"
        exit 1
    fi
    echo "Drasi CRDs found."
}

# Function to apply sources
deploy_sources() {
    echo "Deploying Drasi Sources..."
    
    echo "  - Applying retail-operations-source..."
    kubectl apply -f "$(dirname "$0")/sources/retail-operations-source.yaml"
    
    echo "  - Applying inventory-management-source..."
    kubectl apply -f "$(dirname "$0")/sources/inventory-management-source.yaml"
    
    echo "Sources deployed successfully."
}

# Function to apply continuous queries
deploy_queries() {
    echo "Deploying Continuous Queries..."
    
    echo "  - Applying reorder-monitoring-query..."
    kubectl apply -f "$(dirname "$0")/queries/reorder-monitoring-query.yaml"
    
    echo "  - Applying supplier-delivery-tracking-query..."
    kubectl apply -f "$(dirname "$0")/queries/supplier-delivery-tracking-query.yaml"
    
    echo "Continuous Queries deployed successfully."
}

# Function to apply reactions
deploy_reactions() {
    echo "Deploying Reactions..."
    
    echo "  - Applying reorder-reaction..."
    kubectl apply -f "$(dirname "$0")/reactions/reorder-reaction.yaml"
    
    echo "Reactions deployed successfully."
}

# Function to verify deployment
verify_deployment() {
    echo "Verifying deployment..."
    
    echo "Sources:"
    kubectl get sources -l drasi.io/demo=cncf-webinar
    
    echo ""
    echo "Continuous Queries:"
    kubectl get continuousqueries -l drasi.io/demo=cncf-webinar
    
    echo ""
    echo "Reactions:"
    kubectl get reactions -l drasi.io/demo=cncf-webinar
    
    echo ""
    echo "Deployment verification completed."
}

# Main execution
main() {
    check_kubectl
    check_drasi_crds
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
    echo "3. Monitor query results with: kubectl logs -l app=drasi-query-container"
    echo ""
    echo "For troubleshooting, check:"
    echo "  kubectl describe sources"
    echo "  kubectl describe continuousqueries"
}

main "$@"