output "sns_topic_arn" {
  value = aws_sns_topic.order_updates.arn
}

output "email_queue_url" {
  value = aws_sqs_queue.email_queue.id
}

output "email_queue_arn" {
  value = aws_sqs_queue.email_queue.arn
}