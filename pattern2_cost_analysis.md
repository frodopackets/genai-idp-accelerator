# Pattern 2 IDP Solution Cost Analysis Estimate Report

## Service Overview

Pattern 2 IDP Solution is a fully managed, serverless service that allows you to This project uses multiple AWS services.. This service follows a pay-as-you-go pricing model, making it cost-effective for various workloads.

## Pricing Model

This cost analysis estimate is based on the following pricing model:
- **ON DEMAND** pricing (pay-as-you-go) unless otherwise specified
- Standard service configurations without reserved capacity or savings plans
- No caching or optimization techniques applied

## Assumptions

- 8-hour processing window
- Less than 20 documents, each less than 20 pages
- Average of 15 pages per document
- Documents processed sequentially through the workflow
- Using Claude 3 Haiku model for Bedrock operations
- Textract AnalyzeDocument API for OCR processing
- Standard Lambda concurrency (no reserved capacity)
- Standard S3 storage pricing
- DynamoDB on-demand billing mode

## Limitations and Exclusions

- Initial data ingestion and upload costs to S3
- Cross-region data transfer fees
- CloudWatch monitoring costs beyond basic logging
- Network bandwidth costs
- Development and testing costs
- IAM and security service overhead
- S3 storage costs for input/output documents

## Cost Breakdown

### Unit Pricing Details

| Service | Resource Type | Unit | Price | Free Tier |
|---------|--------------|------|-------|------------|
| AWS Lambda Functions | Requests | request | $0.0000002 | First 1M requests per month free, 400,000 GB-seconds per month free |
| AWS Lambda Functions | Compute | GB-second | $0.0000166667 | First 1M requests per month free, 400,000 GB-seconds per month free |
| Amazon Bedrock (Claude 3 Haiku) | Input Tokens | 1,000 tokens | $0.00025 | No free tier for Bedrock foundation models |
| Amazon Bedrock (Claude 3 Haiku) | Output Tokens | 1,000 tokens | Estimated $0.00125 | No free tier for Bedrock foundation models |
| Amazon Textract | Analyze Document | page (first 1,000,000 pages) | $0.05 | 1,000 pages per month free for first 3 months |
| AWS Step Functions | State Transitions | transition | $0.000025 | 4,000 free state transitions per month |
| Amazon DynamoDB | On Demand Writes | million write requests | $1.25 | 25GB storage, 25 WCU, 25 RCU per month free |
| Amazon DynamoDB | On Demand Reads | million read requests | $0.25 | 25GB storage, 25 WCU, 25 RCU per month free |

### Cost Calculation

| Service | Usage | Calculation | Monthly Cost |
|---------|-------|-------------|-------------|
| AWS Lambda Functions | 6 Lambda functions processing 20 documents over 8 hours (Total Requests: 120 requests (20 docs × 6 functions), Compute Time: 6,000 GB-seconds (assuming 512MB × 1s avg × 120 invocations)) | $0.0000002 × 120 requests + $0.0000166667 × 6,000 GB-seconds = $0.000024 + $0.10 = ~$0.10 | $0.12 |
| Amazon Bedrock (Claude 3 Haiku) | Document classification, extraction, assessment, and summarization for 20 documents (Input Tokens: 1,200,000 tokens (20 docs × 15 pages × 4,000 tokens/page), Output Tokens: 200,000 tokens (structured outputs and summaries)) | $0.00025/1K × 1,200K input + $0.00125/1K × 200K output = $0.30 + $0.25 = $0.55 | $0.60 |
| Amazon Textract | OCR processing for 300 pages (20 docs × 15 pages) (Pages Processed: 300 pages) | $0.05 × 300 pages = $15.00 | $15.00 |
| AWS Step Functions | Orchestrating 20 document processing workflows (State Transitions: 400 transitions (20 docs × ~20 states per workflow)) | $0.000025 × 400 transitions = $0.01 | $0.01 |
| Amazon DynamoDB | Storage and querying of processing results and metadata (Write Requests: 20 write operations, Read Requests: 60 read operations) | $1.25/1M × 0.00002M writes + $0.25/1M × 0.00006M reads ≈ $0.05 | $0.05 |
| **Total** | **All services** | **Sum of all calculations** | **$15.78/month** |

### Free Tier

Free tier information by service:
- **AWS Lambda Functions**: First 1M requests per month free, 400,000 GB-seconds per month free
- **Amazon Bedrock (Claude 3 Haiku)**: No free tier for Bedrock foundation models
- **Amazon Textract**: 1,000 pages per month free for first 3 months
- **AWS Step Functions**: 4,000 free state transitions per month
- **Amazon DynamoDB**: 25GB storage, 25 WCU, 25 RCU per month free

## Cost Scaling with Usage

The following table illustrates how cost estimates scale with different usage levels:

| Service | Low Usage | Medium Usage | High Usage |
|---------|-----------|--------------|------------|
| AWS Lambda Functions | $0/month | $0/month | $0/month |
| Amazon Bedrock (Claude 3 Haiku) | $0/month | $0/month | $1/month |
| Amazon Textract | $7/month | $15/month | $30/month |
| AWS Step Functions | $0/month | $0/month | $0/month |
| Amazon DynamoDB | $0/month | $0/month | $0/month |

### Key Cost Factors

- **AWS Lambda Functions**: 6 Lambda functions processing 20 documents over 8 hours
- **Amazon Bedrock (Claude 3 Haiku)**: Document classification, extraction, assessment, and summarization for 20 documents
- **Amazon Textract**: OCR processing for 300 pages (20 docs × 15 pages)
- **AWS Step Functions**: Orchestrating 20 document processing workflows
- **Amazon DynamoDB**: Storage and querying of processing results and metadata

## Projected Costs Over Time

The following projections show estimated monthly costs over a 12-month period based on different growth patterns:

Base monthly cost calculation:

| Service | Monthly Cost |
|---------|-------------|
| AWS Lambda Functions | $0.12 |
| Amazon Bedrock (Claude 3 Haiku) | $0.60 |
| Amazon Textract | $15.00 |
| AWS Step Functions | $0.01 |
| Amazon DynamoDB | $0.05 |
| **Total Monthly Cost** | **$15** |

| Growth Pattern | Month 1 | Month 3 | Month 6 | Month 12 |
|---------------|---------|---------|---------|----------|
| Steady | $15/mo | $15/mo | $15/mo | $15/mo |
| Moderate | $15/mo | $17/mo | $20/mo | $26/mo |
| Rapid | $15/mo | $19/mo | $25/mo | $45/mo |

* Steady: No monthly growth (1.0x)
* Moderate: 5% monthly growth (1.05x)
* Rapid: 10% monthly growth (1.1x)

## Detailed Cost Analysis

### Pricing Model

ON DEMAND


### Exclusions

- Initial data ingestion and upload costs to S3
- Cross-region data transfer fees
- CloudWatch monitoring costs beyond basic logging
- Network bandwidth costs
- Development and testing costs
- IAM and security service overhead
- S3 storage costs for input/output documents

### Recommendations

#### Immediate Actions

- Consider batch processing multiple documents together to optimize Lambda execution time
- Use CloudWatch to monitor actual token usage and adjust cost estimates
- Leverage AWS Free Tier for initial testing and development phases
#### Best Practices

- Implement error handling and retry logic to avoid unnecessary reprocessing costs
- Monitor Step Functions state transitions to optimize workflow efficiency
- Consider using Bedrock prompt caching for repeated document types
- Implement lifecycle policies for S3 storage to manage long-term costs



## Cost Optimization Recommendations

### Immediate Actions

- Consider batch processing multiple documents together to optimize Lambda execution time
- Use CloudWatch to monitor actual token usage and adjust cost estimates
- Leverage AWS Free Tier for initial testing and development phases

### Best Practices

- Implement error handling and retry logic to avoid unnecessary reprocessing costs
- Monitor Step Functions state transitions to optimize workflow efficiency
- Consider using Bedrock prompt caching for repeated document types

## Conclusion

By following the recommendations in this report, you can optimize your Pattern 2 IDP Solution costs while maintaining performance and reliability. Regular monitoring and adjustment of your usage patterns will help ensure cost efficiency as your workload evolves.
