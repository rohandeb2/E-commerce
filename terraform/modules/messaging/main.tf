# 1. SNS Topic (The Broadcaster)
resource "aws_sns_topic" "order_updates" {
  name              = "${var.project_name}-order-updates"
  kms_master_key_id = var.kms_key_arn # Encryption in transit/at rest

  tags = { Name = "${var.project_name}-order-topic" }
}

# 2. SQS Queue (The Buffer for the Email Service)
resource "aws_sqs_queue" "email_queue" {
  name                      = "${var.project_name}-email-queue"
  message_retention_seconds = 86400 # 1 day retention
  receive_wait_time_seconds = 20    # Long Polling (Reduces cost/CPU)
  
  # Dead Letter Queue (DLQ) integration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
    maxReceiveCount     = 5 # Move to DLQ after 5 failed attempts
  })
}

# 3. Dead Letter Queue (The Safety Net)
resource "aws_sqs_queue" "email_dlq" {
  name = "${var.project_name}-email-dlq"
}

# 4. SQS Queue Policy (Allowing SNS to send messages to SQS)
resource "aws_sqs_queue_policy" "email_queue_policy" {
  queue_url = aws_sqs_queue.email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.email_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": aws_sns_topic.order_updates.arn
          }
        }
      }
    ]
  })
}

# 5. Subscription (Linking SNS to SQS)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.order_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.email_queue.arn
}